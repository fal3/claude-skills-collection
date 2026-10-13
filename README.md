# Swift and Apple platform skills

Reusable guidance for Swift and Apple app development, written for coding agents that can read Markdown. Each skill contains a `SKILL.md`, practical examples or references, and a README. The subject matter is Apple development; the instructions work independently of a particular coding agent.

## Install

```bash
npx skills add fal3/claude-skills-collection
```

That's it. The [skills CLI](https://github.com/vercel-labs/skills) lets you pick skills and agents (Claude Code, Codex, Cursor, Gemini CLI, GitHub Copilot, OpenCode, and more), then installs them.

```bash
# Everything, globally, no prompts
npx skills add fal3/claude-skills-collection --all -g -y

# One skill for Claude Code
npx skills add fal3/claude-skills-collection --skill swiftui-programming-skill -a claude-code

# See what's available
npx skills add fal3/claude-skills-collection --list
```

Update later with `npx skills update`.

### Without Node

The Python installer needs Python 3.9+ and no packages:

```bash
git clone https://github.com/fal3/claude-skills-collection.git
cd claude-skills-collection
python3 scripts/install_skills.py --dest "$HOME/.agents/skills"
```

Add `--skill <folder>` to pick skills, `--update` after a `git pull`, or `--dry-run` to preview. See the [compatibility guide](docs/agent-compatibility.md) for per-agent paths, copy vs. symlink, and Windows notes.

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
| [apple-evaluations](skills/apple-evaluations/README.md) | Generative AI regression testing with Apple's Evaluations framework, datasets, metrics, model judges, and tool trajectories |

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
