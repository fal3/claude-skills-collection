# Swift Modern Architecture Skill

Compatibility-first architecture guidance for Swift 6 apps targeting iOS/iPadOS 18 or macOS 15 with SwiftUI, Observation, structured concurrency, and—when requirements fit—SwiftData.

## When it applies

Use this package for a new feature architecture or an intentional modernization under the stated baseline. It should not activate for every Swift, networking, persistence, concurrency, or test question.

## Baseline

- Xcode 16+
- Swift 6 language mode with complete strict-concurrency checking
- iOS/iPadOS 18+ or macOS 15+

OS 27-cycle APIs are beta relative to the installed stable Xcode 26.6 toolchain. They are outside the default guidance and need explicit user intent, labeling, availability gates, and stable fallbacks.

## Compatibility-first policy

Core Data, Combine/`ObservableObject`, Dispatch/operation queues, and XCTest remain supported tools. This skill recommends alternatives only when the deployment target and feature requirements justify them. Incremental coexistence is often safer than a rewrite:

- SwiftData can be introduced alongside a Core Data stack.
- Observation can coexist with `ObservableObject` in different features.
- Swift concurrency can bridge existing callback, queue, or publisher APIs.
- Swift Testing and XCTest can run side by side.

## Start here

1. [Quick start](docs/QUICK_START.md)
2. [Core skill guidance](SKILL.md)
3. [Complete, typecheckable examples](references/examples.md)
4. [Modern pattern decisions](references/modern-patterns.md)
5. [Failure patterns](references/anti-patterns.md)

## Copy-ready examples

- [Observation ownership](examples/observable_ownership.swift)
- [Latest-request-wins networking](examples/weather_request_cancellation.swift)
- [Correct filtered SwiftData deletion](examples/todo_filtered_delete.swift)
- [Prompt scenarios](examples/prompts.md)

## Documentation

- [Index](docs/INDEX.md)
- [Impact comparison](docs/IMPACT_COMPARISON.md)
- [Package inventory](docs/PACKAGE_SUMMARY.md)

Claims in this package are design guidance, not measured productivity or defect-reduction guarantees. Validate code at the app's oldest deployment target and test migrations against real prior stores.
