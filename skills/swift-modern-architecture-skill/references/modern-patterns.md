# Modern architecture patterns

The package baseline is Swift 6 strict concurrency with iOS/iPadOS 18 or macOS 15. These are defaults for that baseline, not universal rules for every Swift program.

## Choose technology from constraints

### Observation

Use `@Observable` for new UI state when all deployment targets support Observation. A view-created reference belongs in `@State`; an injected reference can be a plain property, with local `@Bindable` for bindings.

Keep `ObservableObject`/Combine when supporting older targets, integrating publisher APIs, or migrating incrementally. Avoid converting stable publisher pipelines merely for fashion.

### Persistence

SwiftData is a strong option when its model, querying, migration, sync, and target support match the feature. Core Data remains appropriate for mature stores and established migration/sync behavior. SQLite layers, files, and cloud services can be better fits for other requirements.

Before choosing, write down:

- relationship and uniqueness rules;
- dataset/query scale;
- background import and concurrency needs;
- CloudKit or other sync constraints;
- extensions and shared-container access;
- migration history, downgrade, export, and recovery needs.

### Asynchrony

Use structured concurrency for new asynchronous flows. Preserve Dispatch or operation queues when an API requires a queue, when interoperating with existing code, or when their scheduling semantics are deliberately used. Bridge at a narrow boundary and test cancellation.

### Testing

Swift Testing is a good fit for new unit/integration tests with parameterization and traits. XCTest remains supported, works alongside it, and continues to cover UI automation and familiar performance-test APIs.

## Feature model pattern

Use a feature model when a screen coordinates asynchronous work, multiple sources of state, or business transitions. A static or locally stateful view often needs no model.

Properties of a robust UI feature model:

- explicit `@MainActor` isolation;
- observable state with restricted setters where useful;
- initializer-injected side-effect dependencies;
- intent methods named for user actions;
- owned task cancellation and request identity;
- distinct idle/loading/content/empty/failure state when the UX needs it.

See [observable ownership](../examples/observable_ownership.swift) and [request cancellation](../examples/weather_request_cancellation.swift).

## Dependency boundaries

Create protocols at stable behavior seams:

```swift
protocol AvatarLoading: Sendable {
    func avatar(for userID: User.ID) async throws -> Avatar
}
```

The types in this fragment (`User` and `Avatar`) are feature-domain types; the snippet illustrates the protocol shape rather than claiming to be standalone.

Good seams often include clocks, ID generation, network clients, persistence repositories, notification authorization, and file access. Avoid “one protocol per concrete type” when no substitution, isolation, or test value exists.

Keep the composition root near the app/scene boundary. Environment injection is useful for subtree-wide dependencies; initializer injection makes local requirements visible.

## Error modeling

Preserve technical errors in logs/telemetry and map them to stable, localized user outcomes. Distinguish:

- cancellation, which normally produces no error UI;
- validation errors the user can correct;
- transient errors that can retry;
- authentication or permission states requiring a different flow;
- data corruption or migration failures requiring recovery.

Do not use `try?` for a side effect whose failure changes user-visible truth.

## Latest-request-wins pattern

Search, selection, and refresh inputs commonly race. A robust implementation:

1. increments a request generation or creates a request ID;
2. cancels the prior owned task;
3. captures the new input and generation;
4. awaits the service;
5. checks cancellation and current generation/input;
6. publishes content/error/loading only for the current request.

Cancellation alone is insufficient because a dependency may complete before it observes cancellation. See [the complete implementation](../examples/weather_request_cancellation.swift).

## SwiftData transaction discipline

- Register the full schema in a tested container.
- Make save failure visible to the caller or UI.
- Roll back intentionally; remember that `rollback()` covers all unsaved changes in that context.
- Resolve `onDelete` offsets against the exact displayed collection.
- Use separate contexts/transactions when independent edits need independent recovery.
- Test uniqueness, relationship deletion, store unavailability, memory pressure, and sync behavior.

See [the filtered-delete implementation](../examples/todo_filtered_delete.swift).

## Migration discipline

Define each shipped model version with `VersionedSchema`, connect versions using `SchemaMigrationPlan`, and choose lightweight or custom stages from the actual schema change. Do not infer migration safety from a fresh in-memory store.

Validation should include:

1. fixture stores from every public schema version;
2. representative scale and relationships;
3. interrupted/failed migration recovery;
4. CloudKit or external-sync constraints;
5. app-extension access and file coordination;
6. backup/export and support diagnostics;
7. rollout and rollback criteria.

SwiftData and Core Data can coexist behind repository boundaries during a staged migration. Keep the old path until real migration and usage evidence supports removal.

## Navigation state

Use `Hashable` values for destinations and keep the path at the scene/feature boundary that owns it. Decode deep links into validated routes. Restoration data is untrusted over time: model versions change and signed-in state may invalidate old routes.

Use a coordinator when it buys something concrete: UIKit bridging, cross-feature orchestration, complex modal policy, or compatibility with an existing navigation system.

## Performance without mythology

- Profile release builds on representative devices.
- Page and filter in the data layer instead of fetching an unbounded store.
- Bound task-group fan-out for large inputs.
- Keep expensive work out of SwiftUI `body`.
- Use stable identity and measure SwiftUI updates with Instruments.
- Do not assume a `LazyVStack` is faster than `List` or that extracting a view guarantees an isolated redraw boundary.

## Security and privacy boundaries

Keep credentials in Keychain-backed storage, not `UserDefaults`. Apply transport policy, validate server trust using platform defaults unless requirements demand more, minimize collected data, and keep private data out of accessibility labels, logs, and analytics. Architecture guidance does not replace a dedicated security/privacy review.
