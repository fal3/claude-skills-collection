# Coding agent compatibility

The same Markdown guidance can be read by any coding agent with file or attachment access. Native skill discovery varies by host, version, settings, and execution environment. The paths below were checked against official documentation on September 17, 2026; this is a documentation check, not a runtime certification for every product.

## Documented discovery paths

| Host | Project paths | Personal paths | Official reference |
|---|---|---|---|
| Codex | `.agents/skills` | `~/.agents/skills` | [Codex skills](https://developers.openai.com/codex/skills/) |
| Claude Code | `.claude/skills` | `~/.claude/skills` | [Claude Code skills](https://code.claude.com/docs/en/skills) |
| Cursor | `.agents/skills`, `.cursor/skills` | `~/.agents/skills`, `~/.cursor/skills` | [Cursor skills](https://cursor.com/docs/skills) |
| GitHub Copilot | `.github/skills`, `.claude/skills`, `.agents/skills` | `~/.copilot/skills`, `~/.agents/skills` | [Copilot agent skills](https://docs.github.com/en/copilot/concepts/agents/about-agent-skills) |
| Gemini CLI | `.gemini/skills`, `.agents/skills` | `~/.gemini/skills`, `~/.agents/skills` | [Gemini CLI skills](https://geminicli.com/docs/cli/skills/) |
| OpenCode | `.opencode/skills`, `.claude/skills`, `.agents/skills` | `~/.config/opencode/skills`, `~/.claude/skills`, `~/.agents/skills` | [OpenCode skills](https://opencode.ai/docs/skills/) |

Pass the chosen directory as `--dest` to [the installer](../scripts/install_skills.py). It does not detect a host or alter its settings. Avoid installing the same package into several directories that one host searches, since duplicate names can change which copy runs.

Personal directories refer to the machine running the agent. A remote or cloud session needs its own installation, a committed project copy, or the host's documented sync or plugin mechanism. Local absolute symlinks do not travel with a Git repository.

## Copy and symlink installations

Copy mode is the default and needs Python 3.9 or later. It copies every supporting file and makes these naming changes only in the installed package:

- The installed folder is the lowercase source folder name.
- `SKILL.md`'s `name` matches that installed folder.
- `agents/openai.yaml`'s `$skill-name` prompt uses the installed folder name.

Older published skills use display names with spaces and capitals in frontmatter. Cursor and OpenCode document stricter identifier rules, so copying raw source folders may fail discovery there. The installer normalizes those identifiers without changing the repository or breaking existing plugin installations. Relative paths inside each package stay the same.

For example, `swiftui-programming-skill` keeps its folder name while its installed frontmatter name becomes `swiftui-programming-skill`. The source folder `swift-SpeechAnalyzer-Framework-Expert` installs as `swift-speechanalyzer-framework-expert`, with a matching frontmatter name and default prompt. Select it using the published source spelling:

```bash
python3 scripts/install_skills.py \
  --dest /path/to/app/.agents/skills \
  --skill swift-SpeechAnalyzer-Framework-Expert
```

The destination manifest `.swift-skills-install.json` records each installed ID, source folder, installation mode, and content digest or symlink target. `--update` uses that record to protect local edits and unrelated packages. It replaces whole unchanged packages, so old packaged files do not linger after an update. A missing managed package can be reinstalled. Removing a source skill does not automatically delete the installed copy.

Symlink mode preserves published folder names and metadata exactly. Use it for local work with a host that accepts those names and follows directory symlinks. It is not a workaround for strict naming validation. On Windows it may require Developer Mode or suitable privileges; copy mode avoids that requirement. To change installation modes, preserve any edits first. The SpeechAnalyzer folder has a different installed ID in each mode, so remove its old entry yourself after checking the replacement works.

Existing unmanaged directories, files, and broken symlinks are conflicts even with `--update`. The installer checks all selections before replacing packages, stages copies before replacement, and restores earlier replacements if a later replacement fails. Rollback removes only entries published by that installation. If an unrelated entry prevents restoring an original package, the installer preserves the backup in the reported staging directory for manual recovery. It refuses nested source symlinks in copy mode to keep copied packages self-contained. Keep backups of personal modifications rather than editing installed copies that you expect to update automatically.

Each real installation holds an operating-system lock for its destination from the manifest read through commit or rollback. A competing installation stops immediately with a message to wait and retry. The empty `.swift-skills-install.lock` file stays in the destination; do not delete it to bypass an active installation. The operating system releases its lock when the process exits, including after a crash, so the file's presence does not mean another installer is running. Lock files must be regular files, not symlinks. This coordinates installers using this script; avoid editing packages with other tools while an installation is running.

`--dry-run` is a read-only snapshot. It creates neither a destination nor a lock file and does not reserve the destination for a later installation. Catchable failures and interruptions roll back uncommitted replacements. A process killed during replacement cannot run rollback; retain any staging directory containing backups and inspect it before retrying. Once the manifest replacement commits, the new packages remain installed even if an interruption arrives immediately afterward.

## Verify discovery and activation

Open the host's skill selector or list command and confirm the installed skill appears. Codex CLI and its IDE extension document `/skills` and `$` mentions; Claude Code and Cursor document `/` selection; Gemini CLI documents `/skills list` and `/skills reload`. For other hosts, follow the linked documentation and use the identifier the host displays.

Use each package's `examples/prompts.md` to try one matching task and one unrelated task. Confirm the host reads the relevant `SKILL.md` for the matching task. Files existing on disk do not prove automatic activation, and a Markdown validator does not measure answer quality.

## Agents without native skills

Keep the checkout in any readable directory and ask the agent to read the exact `SKILL.md` and relevant linked files. If it only accepts attachments, attach those files together. No special command syntax is required by the skill content.

Do not copy the entire collection into always-on rules or a single system prompt. Load the skill that fits the task. The core instructions need no particular agent's tools; adapt file reads, shell commands, browsing, and tests to the tools the host provides. Optional `agents/openai.yaml` metadata and plugin manifests serve their respective hosts and can be ignored by others.

The installer runs on macOS, Linux, and Windows with Python. Apple framework compilation, Xcode projects, Instruments, and simulators still require the relevant Apple environment. A host that can read the instructions may be unable to execute those checks; report that limit explicitly.
