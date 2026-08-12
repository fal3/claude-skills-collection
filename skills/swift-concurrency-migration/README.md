# Swift Concurrency Migration

Use this skill to move an Apple-platform target or Swift package toward Swift 6 strict concurrency without hiding data races or changing every target at once.

## Coverage

- Effective toolchain, language-mode, deployment-target, and build-setting discovery
- Swift 6.2 approachable concurrency and default actor isolation
- `async` versus concurrent execution and appropriate `@concurrent` use
- `Sendable`, actor ownership, reentrancy, structured tasks, and cancellation
- Diagnostic-led migration waves and narrow legacy callback/delegate bridges
- Compile-time and runtime verification

OS 27-cycle APIs are treated as beta relative to stable Xcode 26.6. They require explicit opt-in, beta-SDK compilation, availability gates, and a stable fallback.

## Contents

- [Skill guidance](SKILL.md)
- [Migration workflow and diagnostics](references/migration-workflow.md)
- [Testing and legacy bridges](references/testing-and-bridges.md)
- [Compile-checked Swift example](examples/ConcurrencyMigrationExample.swift)
- [Prompt scenarios](examples/prompts.md)

## Validation expectation

Build every affected scheme and configuration with its intended strict-concurrency settings. Typecheck standalone examples with Swift 6 complete checking, and test cancellation plus adverse callback ordering on the oldest supported OS.
