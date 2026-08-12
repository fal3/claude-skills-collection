# Swift/iOS Skill Collection Hardening Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Correct unsafe or uncompilable guidance, add three focused skills, and make the collection reliably distributable through current Codex and Claude plugin workflows.

**Architecture:** Keep each published skill folder stable, slim `SKILL.md` files into routing and decision guidance, and move detailed examples into directly linked resources. Centralize cross-host metadata, inventories, and deterministic validation at the repository level. Preserve the user's existing uncommitted edits and avoid committing or publishing changes automatically.

**Tech Stack:** Markdown skills, YAML frontmatter, JSON plugin manifests, Ruby/shell validation, Swift 6.3.3, Xcode 26.6, installed Apple SDK interfaces, Codex skill tooling, and Claude plugin validation.

## Global Constraints

- Keep existing published skill directory names stable in this release.
- Preserve unrelated working-tree changes and do not commit, push, or publish.
- Target stable SDK APIs by default; gate beta-cycle APIs with availability checks and document a stable fallback.
- Declare the minimum Swift, Xcode, and platform versions for each skill or example.
- Keep every `SKILL.md` below 500 lines and link supporting resources directly.
- Use only `name` and `description` for portable skill frontmatter; put trigger language in `description`.
- Use `try`/`do-catch` for persistence failures; never teach silent data-loss patterns with `try? save()`.
- Compile substantive Swift examples with Swift 6 strict concurrency where their dependencies permit it.

---

### Task 1: Correct the existing skill collection

**Files:**
- Modify: `skills/*/SKILL.md`
- Modify: `skills/*/README.md`
- Modify: existing `skills/*/examples/` and `skills/swift-modern-architecture-skill/references/`

**Interfaces:**
- Consumes: the audit findings and installed Apple SDK documentation.
- Produces: nine stable, scoped skills with coherent deployment requirements and compile-ready examples.

- [x] Replace nonexistent Speech framework APIs and implement permission, asset, result-task, conversion, finalization, and locale-release lifecycles.
- [x] Replace false ARC cycles and unsafe timer/unowned patterns with ownership graphs that demonstrate the claimed behavior.
- [x] Fix filtered deletion, stale-request races, save-error suppression, incomplete initializers, and blanket framework bans in architecture guidance.
- [x] Teach Swift Testing for unit/integration work and XCTest for UI/performance/legacy work; replace the invalid URLSession subclass mock.
- [x] Fix Lottie type collisions, Canvas scheduling, Core Animation layout, and Reduce Motion fallbacks.
- [x] Repair accessibility grouping, Dynamic Type, hints, and target-size guidance.
- [x] Correct SwiftUI/performance mental models, cross-platform availability, and declared deployment targets.
- [x] Type-check all dependency-free examples and document dependency-bound validation limits.

### Task 2: Add three focused skills

**Files:**
- Create: `skills/swift-concurrency-migration/`
- Create: `skills/swiftdata-core-data-migrations/`
- Create: `skills/app-intents-widgets/`

**Interfaces:**
- Consumes: Xcode concurrency, SwiftData, App Intents, and WidgetKit documentation.
- Produces: concise workflow skills with direct reference routing, user documentation, positive/negative trigger fixtures, and Codex UI metadata.

- [x] Initialize each directory with the official skill scaffolder.
- [x] Implement a concurrency migration workflow covering target detection, isolation strategy, `Sendable`, cancellation, legacy bridging, diagnostics, and verification.
- [x] Implement a persistence decision/migration workflow covering SwiftData vs Core Data, versioned schemas, coexistence, CloudKit constraints, rollback, and production-store testing.
- [x] Implement an App Intents/WidgetKit workflow covering intent/entity scope, shortcuts, widget configuration, controls, shared data, deep-link handoff, and availability.
- [x] Add focused references and compile-ready examples without duplicating them in `SKILL.md`.
- [x] Run skill validation and blind forward tests.

### Task 3: Modernize distribution and discovery

**Files:**
- Create: `.codex-plugin/plugin.json`
- Modify: `.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `README.md`, `AGENTS.md`, `CLAUDE.md`, and `CODEX.md`
- Create or update: `skills/*/agents/openai.yaml`

**Interfaces:**
- Consumes: twelve skill directories.
- Produces: matching Codex/Claude inventories and current installation guidance.

- [x] Add a universal Codex plugin manifest and fix strict Claude marketplace metadata.
- [x] Bump the compatible plugin release version and list all twelve skills.
- [x] Replace legacy Codex installation paths with current `.agents/skills` and plugin options.
- [x] Add deterministic UI metadata for each skill while preserving published invocation compatibility.
- [x] Remove missing archive links, generated-environment paths, and unsupported marketing claims.

### Task 4: Add regression validation

**Files:**
- Create: `scripts/validate_skills.rb`
- Create: `scripts/typecheck_examples.sh`
- Create: `.github/workflows/validate.yml`

**Interfaces:**
- Consumes: repository skill and plugin structure.
- Produces: nonzero exits for invalid metadata, stale inventories, broken links/fences, duplicate trigger scope, or failed dependency-free Swift examples.

- [x] Validate frontmatter, required files, names, descriptions, and line budgets.
- [x] Validate repository inventories, JSON manifests, relative links, and fenced blocks.
- [x] Validate trigger fixtures include positive and negative cases.
- [x] Type-check examples at their declared minimum deployment target when possible and at the installed current SDK.
- [x] Configure the same checks in GitHub Actions on macOS.

### Task 5: Final verification

**Files:**
- Review: all changed paths from `git diff --name-status`

**Interfaces:**
- Consumes: all preceding tasks.
- Produces: a release-ready working tree without hidden publication actions.

- [x] Run the repository validator, example type-checker, Codex skill validator, Claude normal/strict plugin validation, `git diff --check`, and link checks.
- [x] Forward-test each new skill with a context-isolated agent and inspect raw outputs.
- [x] Compare the final diff with the initial dirty-tree snapshot to ensure existing user edits were preserved.
- [x] Report exact remaining limitations; do not claim completion if any required check fails.
