# Swift Unit Testing Skill

Use this skill to design deterministic Swift tests and choose the correct Apple testing framework.

## Baseline

- Swift 6 and Xcode 16 or newer for Swift Testing.
- Swift Testing is the default for new Swift unit and integration tests.
- XCTest remains the right tool for UI automation, performance metrics, Objective-C interoperability, and legacy suites.
- Deployment targets depend on the production APIs under test; state them in generated guidance.

## Included examples

- `examples/example_basic_test.swift`: `@Test`, `#expect`, `#require`, suites, and parameterized cases.
- `examples/example_async_test.swift`: async dependency injection with a production `URLSession` adapter and deterministic stubs.
- `examples/prompts.md`: representative requests that should activate the skill.

The example files are standalone teaching fixtures. In an application, place the system under test in the app or package target and import that module from the test target.

## Principles

- Test observable behavior.
- Await asynchronous work instead of relying on timing.
- Inject network, clock, randomness, and persistence boundaries.
- Keep parallel tests isolated.
- Use accessibility identifiers and explicit waits in UI tests.
- Use XCTest metrics and baselines for performance work.

Resources: [Swift Testing](https://developer.apple.com/xcode/swift-testing/), [Testing documentation](https://developer.apple.com/documentation/testing/), and [XCTest](https://developer.apple.com/documentation/xctest/).
