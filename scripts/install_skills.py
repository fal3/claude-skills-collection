#!/usr/bin/env python3
"""Install this collection into an explicitly chosen skill directory (Python 3.9+)."""

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import sys
import tempfile


SOURCE = Path(__file__).resolve().parent.parent / "skills"
MANIFEST = ".swift-skills-install.json"


class InstallError(Exception):
    pass


def present(path):
    return path.exists() or path.is_symlink()


def within(path, parent):
    try:
        path.relative_to(parent)
        return True
    except ValueError:
        return False


def portable_content(relative, content, source_name, installed_name):
    if relative == "SKILL.md":
        text = content.decode("utf-8").replace("\r\n", "\n")
        parts = text.split("\n---", 1)
        if not text.startswith("---\n") or len(parts) != 2:
            raise InstallError(f"Invalid frontmatter in {source_name}/SKILL.md")
        header, count = re.subn(r"(?m)^name:[^\n]*$", f"name: {installed_name}", parts[0])
        if count != 1:
            raise InstallError(f"Expected one name field in {source_name}/SKILL.md")
        return (header + "\n---" + parts[1]).encode("utf-8")
    if relative == "agents/openai.yaml":
        return content.replace(f"${source_name}".encode(), f"${installed_name}".encode())
    return content


def tree_digest(root, transform=None):
    digest = hashlib.sha256()
    for path in sorted(root.rglob("*")):
        relative = path.relative_to(root).as_posix()
        if path.is_symlink():
            raise InstallError(f"Refusing a symlink inside a copied skill: {path}")
        if not path.is_file() and not path.is_dir():
            raise InstallError(f"Unsupported file type: {path}")
        kind = b"d" if path.is_dir() else b"f"
        content = b"" if path.is_dir() else path.read_bytes()
        if transform and path.is_file():
            content = transform(relative, content)
        digest.update(kind + relative.encode("utf-8") + b"\0")
        digest.update(len(content).to_bytes(8, "big") + content)
    return digest.hexdigest()


def load_manifest(destination):
    path = destination / MANIFEST
    if path.is_symlink():
        raise InstallError(f"Refusing a symlinked install manifest: {path}")
    if not path.exists():
        return {"version": 1, "skills": {}}
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        if not isinstance(data, dict) or data.get("version") != 1 or not isinstance(data.get("skills"), dict):
            raise ValueError("unsupported manifest format")
        for name, entry in data["skills"].items():
            if not isinstance(entry, dict) or entry.get("mode") not in ("copy", "symlink"):
                raise ValueError(f"invalid entry: {name}")
            field = "digest" if entry["mode"] == "copy" else "target"
            if not isinstance(entry.get(field), str):
                raise ValueError(f"invalid {field}: {name}")
        return data
    except (ValueError, OSError) as error:
        raise InstallError(f"Cannot read install manifest {path}: {error}") from error


def matches(target, entry):
    if entry["mode"] == "symlink":
        return target.is_symlink() and target.resolve() == Path(entry["target"]).resolve()
    return target.is_dir() and not target.is_symlink() and tree_digest(target) == entry["digest"]


def remove_entry(path):
    if path.is_symlink() or path.is_file():
        path.unlink()
    elif path.exists():
        shutil.rmtree(path)


def install(destination, mode="copy", selected=None, update=False, dry_run=False, source=SOURCE):
    source = source.resolve()
    destination = destination.expanduser().resolve()
    if within(destination, source):
        raise InstallError("The destination must be outside the source skills directory.")
    if destination.exists() and not destination.is_dir():
        raise InstallError(f"Destination is not a directory: {destination}")
    available = {p.name: p for p in source.iterdir() if p.is_dir() and (p / "SKILL.md").is_file()}
    names = sorted(set(selected or available))
    unknown = set(names) - available.keys()
    if unknown:
        raise InstallError(f"Unknown skill: {', '.join(sorted(unknown))}")
    if not names:
        raise InstallError(f"No skills found in {source}")
    manifest = load_manifest(destination)
    plan = []
    installed_names = set()
    for name in names:
        skill = available[name]
        if skill.is_symlink():
            raise InstallError(f"Source skill must be a real directory: {skill}")
        installed_name = name.lower() if mode == "copy" else name
        if mode == "copy" and not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", installed_name):
            raise InstallError(f"Cannot derive a portable name for {name}")
        if len(installed_name) > 64 or installed_name in installed_names:
            raise InstallError(f"Invalid or duplicate install name: {installed_name}")
        installed_names.add(installed_name)
        transform = lambda rel, data, n=name, i=installed_name: portable_content(rel, data, n, i)
        entry = {"source_name": name, "mode": mode}
        if mode == "copy":
            entry["digest"] = tree_digest(skill, transform)
        else:
            entry["target"] = str(skill)
        target = destination / installed_name
        previous = manifest["skills"].get(installed_name)
        exists = present(target)
        if exists:
            if previous is None:
                raise InstallError(f"Already exists and is not managed by this installer: {target}")
            if not matches(target, previous):
                raise InstallError(f"Local changes detected; preserve or move this entry before updating: {target}")
            if entry == previous:
                print(f"Unchanged: {target}")
                continue
            if not update:
                raise InstallError(f"An update is available for {target}; rerun with --update.")
        plan.append((skill, target, entry, transform, exists))
    for _, target, _, _, exists in plan:
        print(f"{'Would update' if exists else 'Would install'}: {target}")
    if dry_run or not plan:
        return

    destination.mkdir(parents=True, exist_ok=True)
    # Stage every package before touching existing entries. A failed replacement
    # rolls earlier replacements back while the original manifest remains intact.
    with tempfile.TemporaryDirectory(prefix=".swift-skills-stage-", dir=destination) as temporary:
        stage = Path(temporary)
        for index, (skill, _, entry, transform, _) in enumerate(plan):
            staged = stage / str(index)
            if mode == "symlink":
                try:
                    staged.symlink_to(skill, target_is_directory=True)
                except OSError as error:
                    raise InstallError("This system could not create a symlink; use --mode copy.") from error
            else:
                shutil.copytree(skill, staged, symlinks=True)
                for relative in ("SKILL.md", "agents/openai.yaml"):
                    path = staged / relative
                    if path.is_file():
                        path.write_bytes(transform(relative, path.read_bytes()))
                if tree_digest(staged) != entry["digest"]:
                    raise InstallError(f"Source changed while copying {skill}; retry the installation.")
        replaced = []
        try:
            for index, (_, target, entry, _, existed) in enumerate(plan):
                if present(target) != existed or (existed and not matches(target, manifest["skills"][target.name])):
                    raise InstallError(f"Destination changed during installation: {target}")
                backup = stage / f"backup-{index}"
                if existed:
                    target.rename(backup)
                replaced.append((target, backup))
                (stage / str(index)).rename(target)
                manifest["skills"][target.name] = entry
            staged_manifest = stage / "manifest.json"
            staged_manifest.write_text(json.dumps(manifest, indent=2, sort_keys=True) + "\n", encoding="utf-8")
            staged_manifest.replace(destination / MANIFEST)
        except BaseException:
            for target, backup in reversed(replaced):
                remove_entry(target)
                if present(backup):
                    backup.rename(target)
            raise
    print(f"Installed {len(plan)} skill(s) in {destination}")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dest", type=Path, required=True, help="Destination skills directory; no host is assumed")
    parser.add_argument("--mode", choices=("copy", "symlink"), default="copy", help="Copy normalizes legacy names; symlink preserves original metadata")
    parser.add_argument("--skill", action="append", help="Source skill folder to install; repeat to select several (default: all)")
    parser.add_argument("--update", action="store_true", help="Replace only unchanged installer-managed entries")
    parser.add_argument("--dry-run", action="store_true", help="Check and display the plan without writing")
    args = parser.parse_args()
    try:
        install(args.dest, args.mode, args.skill, args.update, args.dry_run)
    except (InstallError, OSError, UnicodeError) as error:
        print(f"Installation stopped: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
