# Swift and Apple platform skills

Reusable guidance for Swift and Apple app development, written for coding agents that can read Markdown. Each skill contains a `SKILL.md`, practical examples or references, and a README. The subject matter is Apple development; the instructions work independently of a particular coding agent.

## Install

Clone the collection outside your app repository, then choose the skill directory your agent reads. The installer needs Python 3.9 or later and no third-party packages.

```bash
git clone https://github.com/fal3/claude-skills-collection.git
cd claude-skills-collection
python3 scripts/install_skills.py --dest "$HOME/.agents/skills"
```

On Windows PowerShell, use a copy installation:

```powershell
git clone https://github.com/fal3/claude-skills-collection.git
Set-Location claude-skills-collection
py -3 scripts/install_skills.py --dest "$HOME/.agents/skills"
```

The default copies the whole skill package and normalizes legacy names in the installed copy for agents with strict naming rules. It preserves the repository's published names and plugin identifiers. Existing unrelated files are never adopted or overwritten. A repeated install of unchanged content does nothing.

These are documented discovery paths, not a claim that every host has been tested with this collection. The [compatibility guide](docs/agent-compatibility.md) links to each host's documentation and explains naming, invocation, and cloud limitations.

| Coding agent | Project destination | Personal destination |
|---|---|---|
| Codex | `/path/to/app/.agents/skills` | `~/.agents/skills` |
| Claude Code | `/path/to/app/.claude/skills` | `~/.claude/skills` |
| Cursor | `/path/to/app/.cursor/skills` | `~/.cursor/skills` |
| GitHub Copilot | `/path/to/app/.github/skills` | `~/.copilot/skills` |
| Gemini CLI | `/path/to/app/.gemini/skills` | `~/.gemini/skills` |
| OpenCode | `/path/to/app/.opencode/skills` | `~/.config/opencode/skills` |
| Other agents | Any readable directory | Ask the agent to read the skill explicitly |

For a project installation or a single skill:

```bash
python3 scripts/install_skills.py \
  --dest /path/to/app/.agents/skills \
  --skill swiftui-programming-skill
```

Repeat `--skill` to select several source folders. Omit it to install the collection. Use `--dry-run` to check the plan without writing files.

## Update an installation

```bash
git pull --ff-only
python3 scripts/install_skills.py --dest "$HOME/.agents/skills" --update
```

`--update` replaces only unchanged entries recorded in `.swift-skills-install.json`. Replacement removes files that the source package no longer includes. If you edited an installed package, the installer stops so you can preserve those edits before replacing it. It leaves unrelated skills alone and does not remove skills that disappear from the collection. Keep the manifest with the installation so future runs can recognize managed entries.

For local development, `--mode symlink` links to the checkout and reflects edits immediately. It preserves legacy metadata, so use it only with hosts that accept those names. Symlinks also require operating system permission and a checkout that stays at the same path. Copy mode is the portable default, including on Windows. See [installation details](docs/agent-compatibility.md#copy-and-symlink-installations).

### Claude Code plugin

The existing plugin remains available with its published name:

```text
/plugin marketplace add https://github.com/fal3/claude-skills-collection
/plugin install ios-swift-skills
```

The repository includes `.codex-plugin/plugin.json` for Codex plugin packaging. A manifest in this repository does not mean the plugin has been published to a public catalog.

## Skills

| Skill folder | Use it for |
|---|---|
| [swiftui-programming-skill](skills/swiftui-programming-skill/README.md) | SwiftUI views, state, navigation, layout, and SF Symbols |
| [swift-modern-architecture-skill](skills/swift-modern-architecture-skill/README.md) | Swift 6 architecture, SwiftData, Observation, and modern concurrency |
| [ios-accessibility-skill](skills/ios-accessibility-skill/README.md) | VoiceOver, Dynamic Type, and accessibility reviews |
| [swift-performance-optimization-skill](skills/swift-performance-optimization-skill/README.md) | Profiling, Instruments, and performance problems |
| [cross-platform-app-development-skill](skills/cross-platform-app-development-skill/README.md) | Shared Apple app architecture and platform adaptations |
| [swift-unit-testing-skill](skills/swift-unit-testing-skill/README.md) | Swift Testing, XCTest, test doubles, and test design |
| [ios-animation-graphics-skill](skills/ios-animation-graphics-skill/README.md) | SwiftUI animation, Canvas, and graphics |
| [memory-leak-diagnosis-skill](skills/memory-leak-diagnosis-skill/README.md) | ARC, retain cycles, and memory leak diagnosis |
| [swift-SpeechAnalyzer-Framework-Expert](skills/swift-SpeechAnalyzer-Framework-Expert/README.md) | SpeechAnalyzer and SpeechTranscriber on iOS 26+ and macOS 26+ |
| [swift-concurrency-migration](skills/swift-concurrency-migration/README.md) | Swift 6 migration, Sendable, and actor isolation diagnostics |
| [swiftdata-core-data-migrations](skills/swiftdata-core-data-migrations/README.md) | Schema changes, store upgrades, and persistence migrations |
| [app-intents-widgets](skills/app-intents-widgets/README.md) | App Intents, App Shortcuts, WidgetKit, and system surfaces |
| [iphone-duo-design](skills/iphone-duo-design/README.md) | iPhone Duo layouts, folding, vertical bars, continuity, scenes, camera, and readiness reviews |

Each skill declares its own toolchain and deployment requirements. Reading a skill does not require macOS; compiling Apple framework examples and running simulators requires a compatible Apple toolchain.

## Use a skill

In an agent with native skill support, select a skill from its skill menu or describe a matching task. Invocation syntax and automatic activation depend on the host.

For any agent that can read local files, use a direct instruction:

```text
Read /absolute/path/to/claude-skills-collection/skills/ios-accessibility-skill/SKILL.md
and its relevant linked references. Use that guidance to review this screen's
VoiceOver order and Dynamic Type layout. Check the app's deployment target first.
```

If the agent cannot read local files, attach the skill and the references the task needs. A successful installation copies instructions; it does not verify the host loaded them or grant access to Xcode, a simulator, or external services.

## Contribute

[AGENTS.md](AGENTS.md) contains the shared repository rules. [CONTRIBUTING.md](CONTRIBUTING.md) explains the package structure and validation commands. [CLAUDE.md](CLAUDE.md) and [CODEX.md](CODEX.md) point hosts and contributors to the same rules.

The core content lives in `skills/`. Host packaging lives in `.claude-plugin/` and `.codex-plugin/`, and optional UI metadata lives in each skill's `agents/openai.yaml`. Keep host-specific setup outside the skill's core procedure.

MIT licensed. Maintained by [@fal3](https://github.com/fal3).
