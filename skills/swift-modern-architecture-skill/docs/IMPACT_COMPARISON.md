# Modernization impact comparison

Architecture choices trade one set of costs for another. Validate them against the app rather than assigning universal scores.

| Change | Potential benefit | Compatibility/risk | Evidence before rollout |
|---|---|---|---|
| `ObservableObject` to Observation | Less wrapper boilerplate; granular tracking | Requires supported OS; ownership mistakes are easy; publisher APIs may still matter | State-lifetime tests, UI behavior, oldest-target build |
| Core Data to SwiftData | Swift-native model/query ergonomics | Migration and feature gaps; mature schema/sync behavior may be costly to reproduce | Every shipped-store fixture, scale tests, sync and rollback plan |
| Callbacks/queues to async/await | Structured flow and cancellation | Isolation/`Sendable` work; bridging semantics can change | Strict-concurrency build, cancellation/race tests, trace comparison |
| XCTest unit tests to Swift Testing | Parameterization and modern test organization | Existing helpers/reporting; XCTest remains for UI/performance workflows | CI discovery, parallelism, reporting, mixed-target run |
| Imperative navigation to value routes | Testable state and restoration | Deep-link/state migration; UIKit bridges | Route validation, restoration and signed-out tests |

## Prefer incremental change when

- a production store has multiple shipped schema versions;
- extensions, widgets, CloudKit, or background imports share data;
- a broad Combine/queue contract crosses modules;
- existing UI tests protect critical flows;
- rollback must remain possible during staged deployment.

Use adapters and feature flags so implementations can coexist. Remove the previous implementation after migration telemetry, correctness checks, and support outcomes are understood.

## A rewrite may be reasonable when

- the feature is new or isolated;
- there is no user-data migration;
- target support is unambiguous;
- behavior is characterized by tests;
- rollout and rollback are cheap;
- the new design solves a concrete product or maintenance problem.

## Review questions

1. What user or engineering outcome justifies the change?
2. What supported platform or behavior would be lost?
3. What data must survive, and from which public versions?
4. Which requests, tasks, and UI models own lifetime and actor isolation?
5. How will stale responses, cancellation, and save failures be tested?
6. Can old and new implementations coexist during rollout?
7. What metric or support signal determines success or rollback?

No fixed percentage, time-saved estimate, or “zero issue” claim applies across projects.
