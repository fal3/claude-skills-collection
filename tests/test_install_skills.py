"""Filesystem regressions for the portable installer. Run with unittest discover."""

import contextlib
import importlib.util
import io
import json
from pathlib import Path
import queue
import subprocess
import sys
import tempfile
import threading
import unittest
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "install_skills.py"
SPEC = importlib.util.spec_from_file_location("install_skills", SCRIPT)
installer = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(installer)


PROCESS_INSTALL = """
import importlib.util
from pathlib import Path
import sys
spec = importlib.util.spec_from_file_location("installer", sys.argv[1])
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
if sys.argv[4] == "pause":
    original_load = module.load_manifest
    def paused_load(destination):
        print("LOCK_HELD", flush=True)
        if not sys.stdin.readline():
            raise RuntimeError("Test controller closed the pipe")
        return original_load(destination)
    module.load_manifest = paused_load
try:
    module.install(Path(sys.argv[3]), source=Path(sys.argv[2]),
                   selected=None if sys.argv[5] == "*" else [sys.argv[5]],
                   update=sys.argv[6] == "update")
except BaseException as error:
    print(str(error), file=sys.stderr)
    sys.exit(1)
"""


class InstallerTests(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name)
        self.source = self.root / "source skills"
        self.source.mkdir()
        self.destination = self.root / "project with spaces" / ".agents" / "skills"
        self.make_skill("alpha-skill")

    def make_skill(self, name, frontmatter_name="Example Skill"):
        folder = self.source / name
        folder.mkdir()
        (folder / "SKILL.md").write_text(f"---\nname: {frontmatter_name}\ndescription: Use for examples; not for production.\n---\nRead [guide](references/guide.md).\n", encoding="utf-8")
        (folder / "references").mkdir()
        (folder / "references" / "guide.md").write_text("Original guide\n", encoding="utf-8")
        (folder / "agents").mkdir()
        (folder / "agents" / "openai.yaml").write_text(f'interface:\n  default_prompt: "Use ${name} to help."\n', encoding="utf-8")
        return folder

    def install(self, **kwargs):
        with contextlib.redirect_stdout(io.StringIO()):
            installer.install(self.destination, source=self.source, **kwargs)

    def process_command(self, mode="run", selected="*", update=False):
        return [sys.executable, "-u", "-c", PROCESS_INSTALL, str(SCRIPT), str(self.source),
                str(self.destination), mode, selected, "update" if update else "install"]

    def run_install_process(self, **kwargs):
        return subprocess.run(self.process_command(**kwargs), capture_output=True, text=True, timeout=10)

    def paused_install_process(self, selected="alpha-skill"):
        process = subprocess.Popen(self.process_command(mode="pause", selected=selected),
                                   stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        def cleanup():
            if process.poll() is None:
                process.kill()
            process.communicate(timeout=10)

        self.addCleanup(cleanup)
        ready = queue.Queue()
        threading.Thread(target=lambda: ready.put(process.stdout.readline()), daemon=True).start()
        self.assertEqual(ready.get(timeout=10), "LOCK_HELD\n")
        return process

    def require_symlink(self):
        probe = self.root / "probe"
        try:
            probe.symlink_to(self.source, target_is_directory=True)
            probe.unlink()
        except OSError:
            self.skipTest("Symlink privileges are not available on this runner")

    def test_copy_normalizes_names_and_prompt_without_changing_source(self):
        speech = self.make_skill("swift-SpeechAnalyzer-Framework-Expert", "SpeechAnalyzer Framework Expert")
        original = (speech / "SKILL.md").read_bytes()
        self.install()
        installed = self.destination / "swift-speechanalyzer-framework-expert"
        self.assertIn("name: swift-speechanalyzer-framework-expert\n", (installed / "SKILL.md").read_text())
        self.assertIn("$swift-speechanalyzer-framework-expert", (installed / "agents" / "openai.yaml").read_text())
        self.assertTrue((installed / "references" / "guide.md").is_file())
        self.assertEqual((speech / "SKILL.md").read_bytes(), original)
        manifest = json.loads((self.destination / installer.MANIFEST).read_text())
        self.assertEqual(manifest["skills"][installed.name]["source_name"], speech.name)

    def test_existing_directory_is_unchanged_without_nested_link(self):
        target = self.destination / "alpha-skill"
        target.mkdir(parents=True)
        (target / "personal.md").write_text("Keep me")
        for mode in ("copy", "symlink"):
            with self.subTest(mode=mode), self.assertRaisesRegex(installer.InstallError, "not managed"):
                self.install(mode=mode, update=True)
            self.assertEqual(list(target.iterdir()), [target / "personal.md"])
            self.assertEqual((target / "personal.md").read_text(), "Keep me")
        self.assertFalse((self.destination / installer.MANIFEST).exists())

    def test_default_rerun_is_idempotent(self):
        self.install()
        target = self.destination / "alpha-skill" / "SKILL.md"
        before = target.stat().st_mtime_ns
        manifest = (self.destination / installer.MANIFEST).read_bytes()
        self.install()
        self.assertEqual(target.stat().st_mtime_ns, before)
        self.assertEqual((self.destination / installer.MANIFEST).read_bytes(), manifest)

    def test_crlf_source_installs_and_reruns_without_changes(self):
        source_file = self.source / "alpha-skill" / "SKILL.md"
        source_file.write_bytes(source_file.read_bytes().replace(b"\r\n", b"\n").replace(b"\n", b"\r\n"))
        original = source_file.read_bytes()
        self.install()
        self.install()
        self.assertEqual(source_file.read_bytes(), original)
        self.assertIn(b"name: alpha-skill\n", (self.destination / "alpha-skill" / "SKILL.md").read_bytes())

    def test_update_requires_opt_in_and_removes_stale_packaged_files(self):
        stale = self.source / "alpha-skill" / "obsolete.txt"
        stale.write_text("Old")
        self.install()
        stale.unlink()
        (self.source / "alpha-skill" / "new.txt").write_text("New")
        with self.assertRaisesRegex(installer.InstallError, "--update"):
            self.install()
        self.assertTrue((self.destination / "alpha-skill" / "obsolete.txt").exists())
        self.install(update=True)
        self.assertFalse((self.destination / "alpha-skill" / "obsolete.txt").exists())
        self.assertEqual((self.destination / "alpha-skill" / "new.txt").read_text(), "New")

    def test_update_refuses_edited_or_extra_user_files(self):
        self.install()
        target = self.destination / "alpha-skill" / "personal.txt"
        target.write_text("Keep my changes")
        with self.assertRaisesRegex(installer.InstallError, "Local changes"):
            self.install(update=True)
        self.assertEqual(target.read_text(), "Keep my changes")

    def test_conflict_preflight_installs_nothing(self):
        self.make_skill("zeta-skill")
        self.destination.mkdir(parents=True)
        (self.destination / "zeta-skill").write_text("Existing file")
        with self.assertRaises(installer.InstallError):
            self.install()
        self.assertFalse((self.destination / "alpha-skill").exists())

    def test_selection_preserves_other_skills(self):
        self.make_skill("zeta-skill")
        self.install(selected=["alpha-skill"])
        self.assertFalse((self.destination / "zeta-skill").exists())
        self.install(selected=["zeta-skill"])
        self.assertTrue((self.destination / "alpha-skill").exists())
        manifest = json.loads((self.destination / installer.MANIFEST).read_text())
        self.assertEqual(set(manifest["skills"]), {"alpha-skill", "zeta-skill"})

    def test_unknown_and_traversal_selection_write_nothing(self):
        for name in ("missing", "../alpha-skill", "/tmp/alpha-skill"):
            with self.subTest(name=name), self.assertRaisesRegex(installer.InstallError, "Unknown skill"):
                self.install(selected=[name])
        self.assertFalse(self.destination.exists())

    def test_dry_run_does_not_create_destination(self):
        self.install(dry_run=True)
        self.assertFalse(self.destination.exists())

    def test_dry_run_does_not_create_lock_in_existing_destination(self):
        self.destination.mkdir(parents=True)
        before = installer.tree_digest(self.destination)
        self.install(dry_run=True)
        self.assertEqual(installer.tree_digest(self.destination), before)

    def assert_overlapping_install_is_serialized(self, competing_skill):
        self.make_skill("zeta-skill")
        holder = self.paused_install_process()
        blocked = self.run_install_process(selected=competing_skill)
        self.assertEqual(blocked.returncode, 1, blocked.stdout + blocked.stderr)
        self.assertIn("Another installation", blocked.stderr)
        self.assertIn("retry", blocked.stderr)
        self.assertEqual({path.name for path in self.destination.iterdir()}, {installer.LOCK_FILE})
        output, error = holder.communicate(input="continue\n", timeout=10)
        self.assertEqual(holder.returncode, 0, output + error)
        before = installer.tree_digest(self.destination / "alpha-skill")
        retried = self.run_install_process(selected=competing_skill)
        self.assertEqual(retried.returncode, 0, retried.stdout + retried.stderr)
        self.assertEqual(installer.tree_digest(self.destination / "alpha-skill"), before)
        manifest = json.loads((self.destination / installer.MANIFEST).read_text())
        self.assertEqual(set(manifest["skills"]), {"alpha-skill", competing_skill})

    def test_overlapping_different_selections_preserve_both_manifest_entries(self):
        self.assert_overlapping_install_is_serialized("zeta-skill")

    def test_overlapping_same_selection_preserves_successful_install(self):
        self.assert_overlapping_install_is_serialized("alpha-skill")

    def test_killed_process_releases_persistent_lock(self):
        holder = self.paused_install_process()
        holder.kill()
        holder.communicate(timeout=10)
        self.assertTrue((self.destination / installer.LOCK_FILE).is_file())
        retried = self.run_install_process()
        self.assertEqual(retried.returncode, 0, retried.stdout + retried.stderr)
        self.assertTrue((self.destination / "alpha-skill" / "SKILL.md").is_file())

    def test_lock_symlink_is_rejected_without_touching_referent(self):
        self.require_symlink()
        self.destination.mkdir(parents=True)
        referent = self.root / "personal.txt"
        referent.write_text("Keep me")
        (self.destination / installer.LOCK_FILE).symlink_to(referent)
        with self.assertRaisesRegex(installer.InstallError, "lock.*symlink"):
            self.install()
        self.assertEqual(referent.read_text(), "Keep me")
        self.assertFalse((self.destination / "alpha-skill").exists())

    def test_destination_cannot_recurse_into_source(self):
        for destination in (self.source, self.source / "alpha-skill" / "nested"):
            with self.subTest(destination=destination), self.assertRaisesRegex(installer.InstallError, "outside"):
                installer.install(destination, source=self.source)
        self.assertFalse((self.source / "alpha-skill" / "nested").exists())

    def test_broken_or_foreign_symlink_is_preserved(self):
        self.require_symlink()
        self.destination.mkdir(parents=True)
        target = self.destination / "alpha-skill"
        target.symlink_to(self.root / "missing", target_is_directory=True)
        with self.assertRaisesRegex(installer.InstallError, "not managed"):
            self.install(update=True)
        self.assertTrue(target.is_symlink())

    def test_symlink_mode_is_idempotent_and_does_not_write_source(self):
        self.require_symlink()
        before = installer.tree_digest(self.source)
        self.install(mode="symlink")
        self.install(mode="symlink")
        target = self.destination / "alpha-skill"
        self.assertTrue(target.is_symlink())
        self.assertEqual(target.resolve(), (self.source / "alpha-skill").resolve())
        self.assertEqual(installer.tree_digest(self.source), before)

    def test_copy_rejects_source_symlinks(self):
        self.require_symlink()
        (self.source / "alpha-skill" / "external").symlink_to(self.root / "outside")
        with self.assertRaisesRegex(installer.InstallError, "symlink"):
            self.install()
        self.assertFalse(self.destination.exists())

    def test_invalid_manifest_is_preserved(self):
        self.destination.mkdir(parents=True)
        manifest = self.destination / installer.MANIFEST
        manifest.write_text("not json")
        with self.assertRaisesRegex(installer.InstallError, "manifest"):
            self.install(update=True)
        self.assertEqual(manifest.read_text(), "not json")

    def assert_failed_replacement_rolls_back(self, exception_type):
        self.make_skill("zeta-skill")
        self.install()
        before = installer.tree_digest(self.destination)
        for name in ("alpha-skill", "zeta-skill"):
            (self.source / name / "new.txt").write_text("Update")
        original_rename = Path.rename

        def fail_second(path, target):
            if path.name == "1" and path.parent.name.startswith(".swift-skills-stage-"):
                raise exception_type("Simulated replacement failure")
            return original_rename(path, target)

        with patch.object(Path, "rename", fail_second), self.assertRaisesRegex(exception_type, "Simulated"):
            self.install(update=True)
        self.assertEqual(installer.tree_digest(self.destination), before)
        # A separate process must acquire the lock after failure or Ctrl-C.
        retried = self.run_install_process(update=True)
        self.assertEqual(retried.returncode, 0, retried.stdout + retried.stderr)

    def test_failed_second_replacement_rolls_back_all_entries(self):
        self.assert_failed_replacement_rolls_back(OSError)

    def test_interrupted_replacement_rolls_back_all_entries(self):
        self.assert_failed_replacement_rolls_back(KeyboardInterrupt)

    def test_failed_publication_preserves_newly_appeared_target(self):
        original_rename = Path.rename

        def foreign_target_before_publish(path, target):
            if path.name == "0" and path.parent.name.startswith(".swift-skills-stage-"):
                target.mkdir()
                (target / "personal.txt").write_text("Keep me")
            return original_rename(path, target)

        with patch.object(Path, "rename", foreign_target_before_publish), self.assertRaises(OSError):
            self.install()
        self.assertEqual((self.destination / "alpha-skill" / "personal.txt").read_text(), "Keep me")
        self.assertFalse((self.destination / installer.MANIFEST).exists())
        self.assertFalse(list(self.destination.glob(".swift-skills-stage-*")))

    def test_blocked_restore_preserves_original_backup_and_foreign_target(self):
        self.install()
        original = installer.tree_digest(self.destination / "alpha-skill")
        manifest = (self.destination / installer.MANIFEST).read_bytes()
        (self.source / "alpha-skill" / "new.txt").write_text("Update")
        original_rename = Path.rename

        def foreign_target_before_publish(path, target):
            if path.name == "0" and path.parent.name.startswith(".swift-skills-stage-"):
                target.mkdir()
                (target / "personal.txt").write_text("Keep me")
            return original_rename(path, target)

        with patch.object(Path, "rename", foreign_target_before_publish), self.assertRaisesRegex(installer.InstallError, "Backups remain"):
            self.install(update=True)
        self.assertEqual((self.destination / "alpha-skill" / "personal.txt").read_text(), "Keep me")
        stages = list(self.destination.glob(".swift-skills-stage-*"))
        self.assertEqual(len(stages), 1)
        self.assertEqual(installer.tree_digest(stages[0] / "backup-0"), original)
        self.assertEqual((self.destination / installer.MANIFEST).read_bytes(), manifest)

    def assert_interrupt_after_rename_rolls_back(self, after_publication):
        self.install()
        before = installer.tree_digest(self.destination)
        (self.source / "alpha-skill" / "new.txt").write_text("Update")
        original_rename = Path.rename

        def interrupt_after_rename(path, target):
            result = original_rename(path, target)
            publishing = path.name == "0" and path.parent.name.startswith(".swift-skills-stage-")
            backing_up = path == self.destination.resolve() / "alpha-skill"
            if (after_publication and publishing) or (not after_publication and backing_up):
                raise KeyboardInterrupt("Interrupted after successful rename")
            return result

        with patch.object(Path, "rename", interrupt_after_rename), self.assertRaises(KeyboardInterrupt):
            self.install(update=True)
        self.assertEqual(installer.tree_digest(self.destination), before)

    def test_interrupt_after_backup_move_restores_original(self):
        self.assert_interrupt_after_rename_rolls_back(after_publication=False)

    def test_interrupt_after_publication_restores_original(self):
        self.assert_interrupt_after_rename_rolls_back(after_publication=True)

    def test_interrupt_after_manifest_commit_keeps_consistent_install(self):
        self.install()
        (self.source / "alpha-skill" / "new.txt").write_text("Update")
        original_replace = Path.replace

        def interrupt_after_commit(path, target):
            result = original_replace(path, target)
            if target.name == installer.MANIFEST:
                raise KeyboardInterrupt("Interrupted after committed manifest")
            return result

        with patch.object(Path, "replace", interrupt_after_commit), self.assertRaises(KeyboardInterrupt):
            self.install(update=True)
        manifest = json.loads((self.destination / installer.MANIFEST).read_text())
        self.assertTrue(installer.matches(self.destination / "alpha-skill", manifest["skills"]["alpha-skill"]))
        self.assertEqual((self.destination / "alpha-skill" / "new.txt").read_text(), "Update")
        self.assertFalse(list(self.destination.glob(".swift-skills-stage-*")))
        retried = self.run_install_process()
        self.assertEqual(retried.returncode, 0, retried.stdout + retried.stderr)

    def test_changed_symlink_target_is_preserved(self):
        self.require_symlink()
        self.install(mode="symlink")
        target = self.destination / "alpha-skill"
        replacement = self.make_skill("other-skill")
        target.unlink()
        target.symlink_to(replacement, target_is_directory=True)
        with self.assertRaisesRegex(installer.InstallError, "Local changes"):
            self.install(mode="symlink", selected=["alpha-skill"], update=True)
        self.assertEqual(target.resolve(), replacement.resolve())

    def test_cli_requires_explicit_destination(self):
        result = subprocess.run([sys.executable, str(SCRIPT)], capture_output=True, text=True)
        self.assertEqual(result.returncode, 2)
        self.assertIn("--dest", result.stderr)


if __name__ == "__main__":
    unittest.main()
