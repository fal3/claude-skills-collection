# Architecture failure patterns

These are contextual hazards, not a list of forbidden frameworks.

## Blanket technology replacement

**Hazard:** “Core Data, Combine, Dispatch, and XCTest are obsolete; replace them.”

**Why it fails:** All remain supported and may encode years of tested behavior. A broad rewrite expands migration, concurrency, and rollout risk without proving user value.

**Safer response:** Compare requirements, deployment targets, framework gaps, migration history, and team cost. Permit coexistence and migrate one bounded seam at a time.

## Activation on every Swift question

**Hazard:** Applying an iOS 18 app architecture package to a Swift algorithm, server-side program, UIKit-only screen, or iOS 15 feature.

**Why it fails:** The package's SwiftUI, Observation, and SwiftData assumptions may not exist or may be irrelevant.

**Safer response:** Activate only for explicit new/modernized feature architecture under Swift 6 and the declared OS baseline.

## Unowned observable lifetime

**Hazard:** A view constructs an `@Observable` model as a plain `let` property and assumes SwiftUI preserves it through view reconstruction.

**Why it fails:** The view has not declared ownership to SwiftUI.

**Safer response:** Store a view-created observable reference in `@State`. For injection, receive it as a plain property and use local `@Bindable` only where bindings are required. See [the ownership example](../examples/observable_ownership.swift).

## Implicit UI isolation

**Hazard:** Mutating loading, error, and view state from async methods without `@MainActor` because “Swift 6 defaults to the main actor.”

**Why it fails:** Default actor isolation is a project/compiler setting, not a guarantee of all Swift 6 code.

**Safer response:** Mark UI-observed models `@MainActor` explicitly and design service isolation separately.

## Suppressed persistence errors

**Hazard:** `try? modelContext.save()` after insert, edit, or delete.

**Why it fails:** The UI can imply success while user data was not persisted.

**Safer response:** Catch or propagate the error, roll back when appropriate, and provide retry/recovery UX. Test store failures.

## Deleting by the wrong offsets

**Hazard:** Display `filteredTodos`, then delete `todos[offset]` from the unfiltered query.

**Why it fails:** `IndexSet` belongs to the displayed collection. Different order/content can delete the wrong record.

**Safer response:** Resolve exact model objects from `filteredTodos` before deletion. See [the filtered-delete example](../examples/todo_filtered_delete.swift).

## Fire-and-forget selection tasks

**Hazard:** Start `Task { await load(selection) }` from `didSet` without storing or canceling it.

**Why it fails:** Requests race. An older response or error can overwrite the newest selection, and loading state becomes unreliable.

**Safer response:** Make selection an explicit intent, cancel the owned prior task, and verify request identity after suspension. See [the weather example](../examples/weather_request_cancellation.swift).

## Uninitialized “complete” examples

**Hazard:** Publish a type with stored dependencies but no initializer, reference `APIClient`/models that are not defined, or show a persistence model without required initializers.

**Why it fails:** Copying the advertised example does not compile, obscuring the architectural point.

**Safer response:** Put full source in an example file, declare imports and minima, and typecheck it independently. Use ellipses only in explicitly labeled pseudocode.

## Ad hoc schema migration

**Hazard:** On each launch, fetch every record and mutate missing values as the entire migration strategy.

**Why it fails:** It does not version the schema, reason about incompatible changes, guarantee atomicity, or cover interrupted migration and sync.

**Safer response:** Use `VersionedSchema` and `SchemaMigrationPlan`, test copies of all shipped stores, and define rollback/recovery before release.

## Over-fetching and unbounded fan-out

**Hazard:** Fetch all rows or launch one task per item without a cap.

**Why it fails:** Memory, database time, network pressure, and cancellation latency grow with the dataset.

**Safer response:** Page/filter at the store, bound concurrency, measure representative data, and propagate cancellation.

## Framework-shaped domain

**Hazard:** Let SwiftUI, transport DTOs, or `ModelContext` flow through every domain type.

**Why it fails:** Business rules become harder to test and framework changes spread across features.

**Safer response:** Add boundaries where they buy isolation—side effects, persistence, transport, and cross-feature coordination—without wrapping every value in a protocol.
