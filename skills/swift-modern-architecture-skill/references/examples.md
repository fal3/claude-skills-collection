# Complete architecture examples

These examples are standalone source files rather than fragments with undefined collaborators. They target Xcode 16, Swift 6 strict concurrency, and iOS 18 unless a file says otherwise.

## Observation ownership

[Open `observable_ownership.swift`](../examples/observable_ownership.swift).

The example demonstrates:

- an explicitly `@MainActor` observable UI model;
- view ownership through `@State`;
- local `@Bindable` projection for a text-field binding;
- a small `Sendable` side-effect protocol;
- cancellation distinguished from user-facing failure.

For a model injected by a parent, use a plain stored property in the child. Add a local `@Bindable` only if that child needs bindings. Do not replace view ownership with an untracked plain `let` reference.

## Latest-request-wins networking

[Open `weather_request_cancellation.swift`](../examples/weather_request_cancellation.swift).

The example cancels the prior task and checks a monotonically increasing request generation plus the selected city after the suspension. Both checks matter:

- cancellation is cooperative, so a client may finish before observing cancellation;
- request identity prevents an old response or error from overwriting current state;
- loading state is updated only by the generation that owns it.

Tests should use a controllable client that resumes requests out of order. Verify that the second selection wins, cancellation is not displayed as an error, and a stale first failure cannot clear the second request's loading state.

## Filtered SwiftData deletion

[Open `todo_filtered_delete.swift`](../examples/todo_filtered_delete.swift).

`onDelete` offsets refer to the collection passed to `ForEach`. The example therefore resolves offsets against `displayedTodos`, captures those exact model objects, and deletes them. Resolving the same offsets against the unfiltered query can delete different user records.

The example also:

- checks every offset before indexing;
- reports save failures instead of using `try?`;
- rolls back the context on failure;
- clears the add field only after a successful save.

Rollback affects all unsaved changes in that `ModelContext`. In a more complex editor, isolate transactions or define a recovery flow rather than assuming only one field changed.

## Composition root

Register model types and construct concrete dependencies once near the app boundary:

```swift
import SwiftData
import SwiftUI

@main
struct TodoExampleApp: App {
    var body: some Scene {
        WindowGroup {
            TodoListScreen()
        }
        .modelContainer(for: Todo.self)
    }
}
```

When a real app has widgets, extensions, CloudKit, or multiple configurations, create and test the `ModelContainer` explicitly rather than relying on a one-line default.

## Copying examples safely

1. Confirm the package baseline matches the app target.
2. Copy the whole file and its declared protocol/model dependencies.
3. Replace placeholder user-facing error text with localized product copy.
4. Configure entitlements, model containers, and transport policy for the actual app.
5. Add success, failure, cancellation, stale-response, and persistence-failure tests.
