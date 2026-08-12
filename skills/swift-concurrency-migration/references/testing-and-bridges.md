# Testing, cancellation, and legacy bridges

## Contents

1. One-shot callbacks
2. Repeated callbacks
3. Delegate isolation
4. Cancellation ownership
5. Test strategy

## 1. One-shot callbacks

Prefer an existing async SDK overload. Otherwise use a checked continuation and centralize completion so every path resumes once:

```swift
func loadValue() async throws -> Data {
    try await withCheckedThrowingContinuation { continuation in
        legacyLoader.load { result in
            continuation.resume(with: result)
        }
    }
}
```

Audit whether the callback can occur synchronously, more than once, or never. A continuation does not automatically cancel the underlying operation. When cancellation matters, hold the operation token in a small synchronized bridge and cancel it from `withTaskCancellationHandler`.

Design that bridge as an explicit state machine—typically pending, completed, or cancelled—protected by one lock or equivalent synchronized owner. Registering the operation token must handle a synchronous callback, and callback completion and cancellation must race through the same transition so exactly one winner resumes the continuation. The cancellation winner cancels a token that has already been installed, or immediately cancels a token installed after the state changed. Decide from the legacy API contract whether cancellation resumes with `CancellationError` or merely suppresses an eventual obsolete callback; do not publish a generic bridge until every transition is covered by a deterministic test.

Do not use a continuation for a delegate that produces multiple values.

## 2. Repeated callbacks

Use `AsyncStream` or `AsyncThrowingStream`. Choose an explicit buffering policy and release the underlying observer/delegate in `onTermination`:

```swift
func events() -> AsyncStream<EventSnapshot> {
    AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
        let token = source.observe { event in
            continuation.yield(EventSnapshot(event))
        }
        continuation.onTermination = { @Sendable _ in
            token.cancel()
        }
    }
}
```

Ensure captured tokens are genuinely Sendable or protect them in a synchronized owner. Finish the stream on normal completion and finish throwing on terminal failure.

## 3. Delegate isolation

Treat the delegate method as a framework boundary:

1. Read the framework's callback queue/executor contract.
2. Mark the method `nonisolated` when the protocol requires nonisolated delivery.
3. Extract Sendable fields from framework reference objects before starting a task.
4. Hop to `@MainActor` only for the UI mutation.

```swift
nonisolated func source(_ source: Source, didProduce item: LegacyItem) {
    let snapshot = ItemSnapshot(id: item.id, title: item.title)
    Task { @MainActor [weak self] in
        self?.apply(snapshot)
    }
}
```

Use `MainActor.assumeIsolated` only when documentation guarantees that executor. It executes synchronously and traps if the assumption is false. `@preconcurrency` reduces checking at a legacy boundary; it does not make delivery safe.

## 4. Cancellation ownership

Define who owns every unstructured task:

- A view-lifetime task is cancelled by the view lifecycle.
- A model-owned task is stored and cancelled on replacement and teardown.
- A request child belongs in structured concurrency so its parent cancels it.
- A loop checks cancellation between bounded units of synchronous work.

Do not swallow cancellation with a broad `catch`. Handle it separately or rethrow it:

```swift
do {
    try await operation()
} catch is CancellationError {
    return
} catch {
    report(error)
}
```

## 5. Test strategy

### Compile-time fixtures

Typecheck dependency-free examples with the same Swift version, strictness, default isolation, and target triple as the product. Also build the real scheme because a bare typecheck does not model target boundaries, Objective-C generated interfaces, macros, or all build settings.

### Deterministic async tests

- Inject a controllable clock or suspension point instead of sleeping arbitrary durations.
- Use actors for test spies that receive concurrent calls.
- Assert task cancellation reaches the fake dependency.
- Exercise success, error, immediate callback, delayed callback, and repeated callback cases.
- Test reentrancy by suspending an actor operation, changing state through another call, then resuming it.

### Runtime checks

Run representative UI flows on the oldest supported OS. Exercise delegates on device when simulator delivery differs. Thread Sanitizer and concurrency instrumentation can expose races or contention, but a clean run cannot justify `@unchecked Sendable`.

### Migration completion evidence

Record exact build and test commands, compiler version, scheme/configuration, and results. Diff effective build settings before and after the migration so a clean result cannot be explained by accidentally weakening strict checking.
