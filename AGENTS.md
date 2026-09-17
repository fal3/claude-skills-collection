# AGENTS.md

This file contains shared repository guidance for any coding agent or contributor. Host-specific entry points refer here; the skill content does not depend on a particular agent.

## Repository overview

This repository is a skills collection focused on Swift and iOS development. Each skill is a self-contained directory with a `SKILL.md`, a user-facing `README.md`, and supporting examples or reference material.

## Skills in this repo

- `swiftui-programming-skill` - SwiftUI declarative UI development
- `swift-modern-architecture-skill` - Swift 6 and iOS 18+ architecture patterns
- `ios-accessibility-skill` - VoiceOver, Dynamic Type, and accessibility best practices
- `swift-performance-optimization-skill` - Performance profiling and optimization patterns
- `cross-platform-app-development-skill` - Multi-platform Apple app strategies
- `swift-unit-testing-skill` - Swift Testing and XCTest workflows
- `ios-animation-graphics-skill` - SwiftUI animation and graphics techniques
- `memory-leak-diagnosis-skill` - ARC, retain cycles, and memory leak diagnosis
- `swift-SpeechAnalyzer-Framework-Expert` - SpeechAnalyzer and SpeechTranscriber for on-device transcription on iOS 26+ and macOS 26+
- `swift-concurrency-migration` - Structured Swift 6 concurrency migration and diagnostic workflows
- `swiftdata-core-data-migrations` - SwiftData and Core Data schema, store, and coexistence migrations
- `app-intents-widgets` - App Intents, App Shortcuts, WidgetKit, and system-surface integration
- `iphone-duo-design` - Adaptive iPhone Duo layouts, controls, continuity, scenes, camera, and readiness verification

## Working conventions

- Keep core instructions independent of host tool names, slash commands, plugins, and machine-specific paths. Put host setup in `docs/agent-compatibility.md` or packaging metadata. Describe file reads and validation in terms any capable agent can follow.
- Keep skill changes scoped: update only the relevant skill folder unless a cross-cutting fix is required.
- Preserve each skill structure: `SKILL.md`, `README.md`, and supporting content in `examples/`, `docs/`, or `references/` as appropriate.
- Prefer modern Swift patterns in examples (Swift Concurrency, Observation, SwiftData when appropriate).
- Verify code snippets remain coherent and compile-ready when copied into a project.
- State minimum Swift, Xcode, and Apple platform versions when guidance depends on newer APIs. Do not apply one repository-wide deployment target to every skill.
- Use lowercase kebab-case for new skill directory names. Do not rename an existing published skill without a compatibility and migration plan.
- When adding, removing, or renaming a skill, update the inventories or structural guidance in `AGENTS.md`, `CLAUDE.md`, `CODEX.md`, and `README.md`, plus plugin metadata when its description or version is affected.

## Adding or updating skills

When adding a new skill, follow the same pattern used by existing skills:

1. Create `skills/<skill-name>/SKILL.md` with valid YAML frontmatter containing only `name` and `description`. Put positive triggers, exclusions, and scope boundaries in `description` because hosts use it for implicit activation.
2. Add `skills/<skill-name>/README.md` for user-facing documentation.
3. Add practical examples under `skills/<skill-name>/examples/`, or use `docs/` and `references/` when the skill is primarily a reference package.
4. Add `skills/<skill-name>/agents/openai.yaml` for optional OpenAI host UI metadata; its default prompt should name `$<skill-name>`.
5. Keep guidance concise, keep `SKILL.md` under 500 lines, and avoid duplicating large sections between files.

## Validation checklist

- Confirm `SKILL.md` frontmatter parses and contains exactly `name` and `description`.
- Confirm descriptions explain both when the skill should and should not activate.
- Check that `SKILL.md`, its `README.md`, and supporting examples give consistent guidance.
- Verify internal links and referenced files exist.
- Review Swift snippets against the minimum versions declared by that skill; use a temporary project when compilation matters and no shared build project exists.
- Check repository-level skill inventories whenever the set of skills changes.
- Run `python3 -m unittest discover -s tests -p 'test_*.py'`, `ruby scripts/validate_skills.rb`, and `git diff --check` before handing off changes. Run `bash scripts/typecheck_examples.sh` when Swift examples change, using the declared Apple toolchain.
- Keep installation code compatible with Python 3.9 or later and test path, conflict, update, and rollback behavior. Preserve existing published identifiers; normalize only installed copies when a host requires strict names.
