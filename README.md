# Swift/iOS Skills Collection (Codex + Claude)

This repository contains a curated collection of reusable skills for Swift and iOS development. The same `skills/*/SKILL.md` content can be used from Codex or Claude-style workflows.

## TL;DR - Get Started in 10 Seconds

### Codex
```bash
# From this repository root
mkdir -p "$HOME/.agents/skills"
for skill in "$(pwd)"/skills/*; do
  [ -d "$skill" ] || continue
  ln -sfn "$skill" "$HOME/.agents/skills/$(basename "$skill")"
done
```

Codex discovers the skills automatically. Type `$` to invoke one explicitly, or describe a matching task and let its `description` trigger it.

### Claude Code Plugin
```bash
# In Claude Code, run:
/plugin marketplace add https://github.com/fal3/claude-skills-collection
/plugin install ios-swift-skills
```

---

## Installation

### Codex

Install via symlink so updates in this repository are picked up immediately:

```bash
collection_root="/absolute/path/to/claude-skills-collection"
mkdir -p "$HOME/.agents/skills"
for skill in "$collection_root"/skills/*; do
  [ -d "$skill" ] || continue
  ln -sfn "$skill" "$HOME/.agents/skills/$(basename "$skill")"
done
```

Optional: copy instead of symlink:

```bash
mkdir -p "$HOME/.agents/skills"
cp -R skills/. "$HOME/.agents/skills/"
```

For repository-scoped installation, use the same layout under `$REPO_ROOT/.agents/skills`. The repository also includes `.codex-plugin/plugin.json` for universal plugin packaging; publishing it to a public catalog is a separate release step.

### Claude Code Plugin

**Install the plugin:**
```bash
# Add the marketplace
/plugin marketplace add https://github.com/fal3/claude-skills-collection

# Install the plugin
/plugin install ios-swift-skills
```

**Benefits:**
- All skills are discoverable when relevant
- Explicit skill invocation remains available
- One plugin install exposes the collection
- The installed plugin can be used across projects

All 12 Swift and Apple platform skills are then available automatically.

### 🎯 Alternative: Project-Specific Installation

Clone the repository, then install it through the local marketplace or link the individual skill directories into your project's skill location. Keeping the clone outside the project avoids committing a nested repository by accident.

```bash
git clone https://github.com/fal3/claude-skills-collection.git
```

## Skills Index

All skills are available once installed in either Codex (`$HOME/.agents/skills` or `$REPO_ROOT/.agents/skills`) or Claude Code (plugin install).

### Swift and Apple Platform Development (12 Skills)

| Skill | Description | Activation Keywords |
|-------|-------------|---------------------|
| **swiftui-programming-skill** | SwiftUI declarative UI development | SwiftUI, declarative UI, SF Symbols |
| **swift-modern-architecture-skill** | Swift 6/iOS 18 architecture patterns | Swift 6, iOS 18, SwiftData, modern architecture |
| **ios-accessibility-skill** | iOS accessibility best practices | VoiceOver, Dynamic Type, accessibility |
| **swift-performance-optimization-skill** | Performance optimization techniques | performance, Instruments, optimization |
| **cross-platform-app-development-skill** | Multi-platform app strategies | multi-platform, iPad, Mac Catalyst |
| **swift-unit-testing-skill** | Swift Testing by default, with XCTest for UI, performance, and legacy suites | Swift Testing, XCTest, unit testing, TDD |
| **ios-animation-graphics-skill** | SwiftUI animations and graphics | animations, Canvas, Lottie |
| **memory-leak-diagnosis-skill** | Memory leak detection and fixing | memory leaks, retain cycles, ARC |
| **swift-SpeechAnalyzer-Framework-Expert** | On-device speech transcription with Apple's modern Speech framework | SpeechAnalyzer, SpeechTranscriber, audio transcription |
| **swift-concurrency-migration** | Structured migration to Swift 6 data-race safety | Swift 6 migration, Sendable, actor isolation, concurrency diagnostics |
| **swiftdata-core-data-migrations** | Production-safe SwiftData and Core Data migrations | VersionedSchema, SchemaMigrationPlan, Core Data migration, store upgrade |
| **app-intents-widgets** | App Intents, App Shortcuts, WidgetKit, and system surfaces | AppIntent, AppEntity, App Shortcuts, widgets, controls |

Each skill includes focused best practices, domain-specific guidance, and practical examples or reference implementations.

---

## How It Works

Once installed, skills activate automatically based on your queries:

- Ask about **SwiftUI** → `swiftui-programming-skill` loads
- Mention **memory leaks** → `memory-leak-diagnosis-skill` activates
- Discuss **accessibility** → `ios-accessibility-skill` engages
- Talk about **testing** → `swift-unit-testing-skill` helps
- Ask about **Swift 6 migration errors** → `swift-concurrency-migration` guides the migration
- Plan a **SwiftData/Core Data store upgrade** → `swiftdata-core-data-migrations` protects existing data
- Add **App Intents or widgets** → `app-intents-widgets` scopes the system integration

No manual loading required. Just ask your question and the relevant skills provide expertise.

### Example Usage

```
You: "How do I add VoiceOver labels to my SwiftUI view?"
Claude: [ios-accessibility-skill activates] Here's how to implement VoiceOver...

You: "My app is using too much memory"
Claude: [memory-leak-diagnosis-skill activates] Let's diagnose potential memory leaks...

You: "I need to create a smooth animation"
Claude: [ios-animation-graphics-skill activates] I'll show you SwiftUI animation techniques...
```

Each skill provides:
- Best practices specific to the domain
- Practical examples or reference implementations
- Modern Swift/iOS patterns with skill-specific platform requirements
- Apple platform guidance relevant to the skill

## Contributing

We welcome contributions! To add or improve skills:

1. Fork this repository
2. Add your skill in `skills/your-skill-name/SKILL.md`
3. Follow the skill structure defined in `CLAUDE.md` and `CODEX.md`:
   - YAML frontmatter with only `name` and a trigger-rich `description`
   - Focused, domain-specific best practices
   - Domain-specific guidelines
   - Practical examples or reference implementations
4. Test with Claude Code: `/plugin marketplace add ./your-fork`
5. Submit a pull request

### Guidelines
- Follow Apple's Swift API Design Guidelines
- Declare the minimum Swift, Xcode, and platform versions required by the skill
- Include working, tested examples or reference implementations
- See [CONTRIBUTING.md](CONTRIBUTING.md) for details

### Plugin Structure

This repository is a Claude Code plugin with the following structure:

```
claude-skills-collection/
├── .claude-plugin/
│   ├── plugin.json          # Plugin metadata
│   └── marketplace.json     # Marketplace config
├── .codex-plugin/
│   └── plugin.json          # Universal ChatGPT/Codex plugin manifest
├── skills/                   # All skills here
│   ├── swiftui-programming-skill/
│   │   ├── SKILL.md         # Skill definition
│   │   ├── README.md        # Documentation
│   │   ├── examples/        # Code examples, when appropriate
│   │   ├── docs/            # Optional packaged documentation
│   │   └── references/      # Optional deep-dive material
│   └── ...
├── AGENTS.md              # Authoritative Codex repository instructions
├── CLAUDE.md              # Claude Code repository instructions
└── CODEX.md               # Cross-tool maintenance reference
```

### Roadmap

**Possible future additions:**
- ARKit and RealityKit
- CloudKit integration
- StoreKit and subscription operations
- Localization and internationalization workflows

Want to contribute? Open an issue or submit a PR!

---

**Current Focus:** iOS development. Minimum Swift, Xcode, and platform versions are documented per skill; some skills require newer APIs such as iOS 26+.
**License:** MIT
**Maintained by:** [@fal3](https://github.com/fal3)
