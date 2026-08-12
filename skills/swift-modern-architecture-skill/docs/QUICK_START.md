# Quick start

## 1. Confirm fit

Use this package for an architecture or modernization request targeting Swift 6 strict concurrency with iOS/iPadOS 18 or macOS 15. For older deployment targets or non-SwiftUI apps, choose compatibility guidance instead of forcing this package's defaults.

Record persistence history, sync, extensions, background work, navigation, rollout, and test constraints.

## 2. Choose one feature boundary

Start with a bounded user capability. Separate:

- SwiftUI rendering and user intent;
- optional `@MainActor @Observable` feature coordination;
- pure domain rules;
- small side-effect protocols;
- concrete networking/persistence adapters at the composition root.

Do not create a view model for a view that only needs local `@State`.

## 3. Declare ownership

For a view-owned observable model:

```swift
@MainActor
struct FeatureScreen: View {
    @State private var feature: FeatureModel

    init(client: any FeatureClient) {
        _feature = State(initialValue: FeatureModel(client: client))
    }

    var body: some View {
        @Bindable var feature = feature
        // Bind controls to feature here.
    }
}
```

This fragment assumes complete `FeatureModel` and `FeatureClient` definitions. For a standalone implementation, use [the ownership example](../examples/observable_ownership.swift).

## 4. Make async work replaceable

When input changes rapidly, store the owned task, cancel its predecessor, and check both cancellation and request identity after awaiting. Use [the weather example](../examples/weather_request_cancellation.swift) as the template.

## 5. Persist truthfully

Catch or propagate every meaningful save error. For filtered lists, delete objects resolved from the displayed collection—not the backing query at the same offsets. Use [the Todo example](../examples/todo_filtered_delete.swift).

For schema changes, define a versioned migration and test real prior stores. Do not use a launch-time mutation loop as the migration plan.

## 6. Keep supported compatibility paths

- Retain Core Data when migration risk or required behavior outweighs benefits.
- Retain `ObservableObject`/Combine for older targets and publisher-centric integrations.
- Retain Dispatch/operation queues at APIs or scheduling boundaries that need them.
- Use XCTest for UI/performance tests and existing coverage; add Swift Testing where it improves new unit tests.

## 7. Validate

- Typecheck under Swift 6 complete strict concurrency.
- Build at the oldest declared OS target.
- Test success, failure, cancellation, stale responses, persistence failures, deep links, and restoration.
- Test migration fixtures from every shipped schema.
- Measure release performance before and after architectural changes.
- Roll out incrementally with rollback criteria.
