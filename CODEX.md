# CODEX.md

Read [AGENTS.md](AGENTS.md) for the shared repository rules before making changes. This file is a maintenance reference for Codex and other coding agents. Native discovery is host-specific; see [the compatibility guide](docs/agent-compatibility.md).

## What This Repository Is

- A collection of reusable skills for Swift and iOS development.
- Content-first repo: mostly Markdown and code snippets, not a runnable app.
- Main artifacts are under `skills/*/SKILL.md`, with supporting content in `examples/`, `docs/`, or `references/`.

## Skill Inventory

- `swiftui-programming-skill`
- `swift-modern-architecture-skill`
- `ios-accessibility-skill`
- `swift-performance-optimization-skill`
- `cross-platform-app-development-skill`
- `swift-unit-testing-skill`
- `ios-animation-graphics-skill`
- `memory-leak-diagnosis-skill`
- `swift-SpeechAnalyzer-Framework-Expert`
- `swift-concurrency-migration`
- `swiftdata-core-data-migrations`
- `app-intents-widgets`
- `iphone-duo-design`

## Editing Standards

- Keep instructions concise and practical, independent of a particular agent's tool names or invocation syntax.
- Favor modern Apple platform APIs and current Swift patterns.
- Ensure examples are copy-paste friendly and internally consistent.
- Update skill docs and examples together when behavior or recommendations change.
- State minimum Swift, Xcode, and platform versions when guidance uses version-specific APIs.
- Use lowercase kebab-case for new skill directories; do not rename published skills without a migration plan.

## Skill Structure

Typical skill layout:

```text
skills/<skill-name>/
├── SKILL.md
├── README.md
├── agents/openai.yaml
├── examples/     (when appropriate)
├── docs/         (optional)
└── references/   (optional)
```

## Validation Checklist

- `SKILL.md` frontmatter is valid YAML and contains exactly `name` and `description`; the description includes activation boundaries.
- `SKILL.md` stays under 500 lines and links directly to deeper material instead of duplicating it.
- `agents/openai.yaml` has a default prompt that explicitly names the skill.
- Examples match guidance in `SKILL.md`.
- No references to removed files.
- Repo-level docs (`README.md`, `CONTRIBUTING.md`) still align with the current skill set.
- Swift snippets are checked against the minimum versions declared by their skill; use a temporary project when compilation matters because this repository has no shared build system.
- Repository validators and `git diff --check` pass.

## Installer validation

Run `python3 -m unittest discover -s tests -p 'test_*.py'` for filesystem regressions on any supported operating system. The installer requires Python 3.9 or later. Copy mode normalizes legacy names in installed packages; published source names stay unchanged.
