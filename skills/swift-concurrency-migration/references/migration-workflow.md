# Migration workflow and diagnostic playbook

## Contents

1. Baseline inventory
2. Build-setting strategy
3. Migration waves
4. Diagnostic workflow
5. Review gates

## 1. Baseline inventory

Create a target matrix before touching annotations:

| Target | Kind | Swift mode | Strict checking | Default isolation | Approachable concurrency | Minimum OS |
|---|---|---:|---|---|---|---|
| App | application | inspect | inspect | inspect | inspect | inspect |
| Widget | extension | inspect | inspect | inspect | inspect | inspect |
| Core | library/package | inspect | inspect | inspect | inspect | inspect |
| Tests | test bundle | inspect | inspect | inspect | inspect | inspect |

Then map ownership:

- UI entry points and observed state.
- Mutable global/static state.
- Dispatch queues used as locks versus queues used for scheduling.
- Stored and detached tasks.
- Types crossing closures, tasks, actors, notifications, delegates, and persistence boundaries.
- Imports or conformances already using `@preconcurrency`, `@unchecked Sendable`, or `nonisolated(unsafe)`.

Save a clean build/test result. For a bug, preserve a small failing test or diagnostic fixture before applying a fix.

For a user-facing asynchronous pipeline, record a small behavioral and performance baseline before moving executors: callback ordering, cache/coalescing behavior, p50/p95 latency, main-thread time, peak memory, maximum outstanding work, and work that continues after cancellation. Preserve only the metrics relevant to the feature; concurrency migration is not permission for an unrelated optimization rewrite.

## 2. Build-setting strategy

Use the effective settings printed by `xcodebuild -showBuildSettings`; project-editor defaults are not evidence because target and configuration overrides can differ.

For an app target on Swift 6.2+, consider approachable concurrency plus MainActor default isolation together. For libraries, prefer a nonisolated default unless the entire API is intentionally UI-bound. Do not change the app, widgets, packages, and tests in one switch: their boundaries reveal different diagnostics.

Suggested order:

1. Leaf model/utility packages.
2. Service and persistence targets.
3. Extensions.
4. Main application.
5. Test targets and integration harnesses.

Build all configurations used by CI. A debug-only clean build can miss release-only conditional code.

## 3. Migration waves

### Wave A: Value boundaries

- Add `Sendable` to immutable structs and enums whose stored values are Sendable.
- Replace actor-crossing reference objects with IDs or immutable snapshots.
- Keep Core Data managed objects, UI objects, and other thread-confined framework objects inside their owning domain.
- Avoid retroactive or unchecked conformance to framework types.

### Wave B: Isolation ownership

- Put UI-observed state and UI coordination on `@MainActor`.
- Convert queue-protected, cohesive mutable services to actors when asynchronous access is appropriate.
- Keep synchronous lock-protected primitives as locks when an actor would force awkward async APIs; document invariants.
- Re-check actor state after every suspension point.

### Wave C: Execution intent

- Leave latency-hiding async APIs on the caller's actor unless their synchronous work is expensive.
- Mark CPU-heavy async functions `@concurrent` with a Swift 6.2+ compiler when they must leave caller isolation.
- Do not use `nonisolated` as a synonym for background execution.
- Replace `Task.detached` used only to escape MainActor with a structured operation or an explicit `@concurrent` function.

### Wave D: Task structure and lifetime

- Replace fixed sibling callbacks/dispatch groups with `async let`.
- Replace dynamic fan-out with a throwing task group and bounded concurrency when inputs are large.
- Store feature-lifetime task handles and cancel them during teardown.
- Preserve errors instead of starting an unobserved throwing task.

### Wave E: Legacy edges

- Prefer an SDK's native async overload.
- Wrap a one-shot callback in a checked continuation.
- Wrap repeated delegate/callback events in an AsyncStream with termination cleanup.
- Keep GCD only inside the bridge when a legacy API requires its queue contract.

## 4. Diagnostic workflow

For every diagnostic:

1. Capture the complete message, file, target, configuration, and setting matrix.
2. Identify the two isolation domains and the value crossing between them.
3. Decide which domain owns mutable state.
4. Apply the smallest ownership fix.
5. Rebuild the same target before touching the next diagnostic shape.
6. Search for the same pattern and fix it consistently.

| Diagnostic shape | Investigate | Preferred fixes |
|---|---|---|
| Capture of non-Sendable type in `@Sendable` closure | Mutable reference captured by concurrent work | Send snapshot/ID, isolate in actor, or keep closure on owner |
| Main actor-isolated member used from nonisolated context | Incorrect UI ownership or callback boundary | Isolate caller, hop narrowly, or capture value first |
| Sending value risks data races | Value remains accessible in another domain | Stop later use, copy Sendable state, or use actor ownership |
| Mutation/reference to captured `var` | Shared closure state | Use per-iteration `let`, return results, or actor accumulator |
| Conformance crosses actor boundary | Protocol requirement and implementation isolation differ | Use isolated conformance when supported or explicit bridge |
| Runtime isolation trap despite a clean build | Legacy/ObjC callback bypasses static checking | Verify callback contract and repair boundary; do not suppress |

Do not start by adding `@MainActor` to the reported function. That can move the error downstream or run expensive work on the UI executor.

## 5. Review gates

Before completing a target:

- No new broad suppression annotation exists without an owner and removal condition.
- Every stored or long-lived task has an explicit cancellation owner.
- Every `@concurrent` operation takes and returns Sendable data.
- Every continuation has exactly-one resume logic and a cancellation policy.
- Every actor method revalidates mutable assumptions after `await`.
- The full target builds with its intended Swift mode and strictness.
- Tests cover cancellation and at least one adverse callback ordering.
