# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a reusable skills collection for Claude Code and Codex, focused on Swift and iOS development. It contains curated skills that provide specialized expertise across different iOS/Swift domains. Each skill is a self-contained directory with structured documentation and examples or reference material.

## Repository Structure

The repository follows a consistent pattern:

```
skills/<skill-name>/
├── SKILL.md               # Skill definition with frontmatter and instructions
├── README.md              # User-facing documentation
├── agents/
│   └── openai.yaml        # Optional portable UI metadata
├── examples/              # Practical code and prompts (when appropriate)
│   ├── prompts.md         # Positive and negative activation fixtures
│   └── *.swift            # Working code examples
├── docs/                  # Optional packaged documentation
└── references/            # Optional deep-dive guides
```

### Available Skills

1. **swiftui-programming-skill** - SwiftUI declarative UI development, SF Symbols, state management
2. **swift-modern-architecture-skill** - Swift 6 architecture, SwiftData persistence, Observation framework, modern concurrency
3. **ios-accessibility-skill** - VoiceOver, Dynamic Type, HIG compliance
4. **swift-performance-optimization-skill** - Performance profiling, Instruments usage, memory efficiency
5. **cross-platform-app-development-skill** - Multi-platform app strategies
6. **swift-unit-testing-skill** - Swift Testing, XCTest, TDD, and test doubles
7. **ios-animation-graphics-skill** - SwiftUI Canvas, Lottie animations
8. **memory-leak-diagnosis-skill** - ARC, retain cycles, Instruments Leaks tool
9. **swift-SpeechAnalyzer-Framework-Expert** - SpeechAnalyzer and SpeechTranscriber for on-device transcription on iOS 26+ and macOS 26+
10. **swift-concurrency-migration** - Swift 6 concurrency migration and compiler-diagnostic workflows
11. **swiftdata-core-data-migrations** - Safe SwiftData and Core Data schema/store migrations
12. **app-intents-widgets** - App Intents, App Shortcuts, WidgetKit, and system surfaces

## Working with Skills

### Skill File Structure

Each `SKILL.md` follows this frontmatter format:
```yaml
---
name: <Skill Name>
description: <What the skill does, when to use it, and when not to use it>
---
```

New skills use a lowercase kebab-case `name` matching their directory. Preserve the published `name` value of an existing skill unless a compatibility plan accompanies the change. Hosts use `description` for implicit activation, so front-load useful trigger terms and include exclusions.

### Creating New Skills

When adding a new skill, follow these requirements:

1. **Frontmatter**: Include only `name` and a scope-rich `description`
2. **Best Practices Section**: Focused, domain-specific best practices
3. **Guidelines Section**: Additional domain-specific guidelines with bullet points
4. **Supporting Material**: Add practical examples in `examples/`, or use `docs/` and `references/` when the skill is primarily a reference package
5. **Code Standards**: Code examples must:
   - Follow Swift naming conventions (camelCase, PascalCase for types)
   - Include proper imports
   - Be runnable/compilable where applicable
   - Include explanatory comments where helpful
   - Use modern Swift features (async/await when appropriate)
6. **Portable Metadata**: Add `agents/openai.yaml` with a concise display name, short description, and a default prompt that names `$<skill-name>`
7. **Progressive Disclosure**: Keep `SKILL.md` under 500 lines and link directly to focused examples or references

New skill directories should use lowercase kebab-case. Existing published directories should not be renamed without a compatibility and migration plan.

### Code Quality Standards

All Swift code examples should adhere to:

- **Apple's Swift API Design Guidelines**
- **SwiftUI best practices** for declarative UI code
- **Modern concurrency** patterns (async/await, actors) when applicable
- **Memory safety** patterns (weak/unowned references, avoiding retain cycles)
- **Accessibility-first** design (proper labels, hints, Dynamic Type support)
- **Type safety** and clear error handling
- **Explicit platform baselines** when APIs require particular Swift, Xcode, iOS, macOS, watchOS, or tvOS versions

### Testing Examples

When skills include testing patterns:
- Prefer Swift Testing for new unit and integration tests when the target/toolchain supports it
- Retain XCTest for UI automation, performance tests, Objective-C tests, and legacy suites
- Follow Arrange-Act-Assert structure
- Include both sync and async test examples
- Show proper mocking/dependency injection patterns
- Demonstrate performance testing when relevant

## Contributing

Reference `CONTRIBUTING.md` for contribution guidelines, which include:
- Fork and pull request workflow
- Code must follow Apple's Swift and iOS guidelines
- Update SKILL.md and README.md with changes
- Test all code examples for correctness
- For new skills, include complete directory structure

## Development Notes

### Validation, not an app build
This repository contains documentation and example code snippets, not a runnable app. There is no shared `Package.swift` or Xcode project; repository scripts validate structure and type-check standalone examples against their declared SDK targets.

### Documentation-Focused
The primary artifacts are `.md` files with embedded Swift code blocks. Code examples are illustrative and designed to be copied into real projects.

### Version Management
The plugin manifests carry the collection's semantic version. Individual portable skill frontmatter intentionally contains only `name` and `description`.

### Repository Synchronization
When adding, removing, or renaming a skill, update the inventories or structural guidance in `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, and `README.md`. Update plugin metadata when the change affects the plugin description or release version.
