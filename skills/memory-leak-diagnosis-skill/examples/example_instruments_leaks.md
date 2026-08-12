# Repeatable memory-diagnosis workflow

## 1. Define the lifecycle

Write down the type, expected owner, and release point. Example: “After dismissing `EditorViewController` and allowing its save task to finish, the controller and view model should deinitialize.”

Add temporary `deinit` logs or a debug-only lifetime probe. Record the initial live-instance count.

## 2. Reproduce consistently

Use a release-like build configuration when practical. Repeat the same present/use/dismiss sequence three to five times, returning to the same idle state after each pass. Record settled memory and instance counts; peak memory alone is not proof of a leak.

## 3. Inspect Memory Graph

1. Pause after the object should be released.
2. Open Debug Memory Graph.
3. Search for the concrete stale type.
4. Select an unexpected instance and follow incoming strong references back toward a root.
5. Capture the root path and the lifecycle that installed it.

Do not infer ownership from remembered arrow colors or displayed reference counts. Xcode presentation changes; inspect whether each relationship is strong, weak, unowned, or a runtime/framework root.

## 4. Compare Allocations generations

1. Profile with Instruments Allocations.
2. Mark a generation at the idle baseline.
3. Perform one lifecycle and return to idle.
4. Mark another generation and repeat.
5. Filter to application types and inspect allocations that persist across every generation.

A bounded cache may retain objects intentionally. Verify its limit, eviction policy, and response to memory pressure before calling it a leak.

## 5. Use Leaks for its actual scope

Add the Leaks instrument and inspect reported unreachable heap allocations and their allocation backtraces. A clean Leaks track does not prove that a controller retained by a task, timer, observer, or framework root was released.

Use VM Tracker when growth comes from mapped files, image surfaces, graphics resources, or other virtual-memory regions rather than Swift object counts.

## 6. Audit common owners

- Stored closures and callback registries
- Tasks, continuations, and AsyncStream termination
- Notification and Combine tokens
- Timers, display links, and animation callbacks
- Delegates, data sources, KVO, and URLSession delegates
- SwiftUI state/environment models and presentation closures
- Core Data / SwiftData contexts
- Image, response, and decoded-data caches

## 7. Verify the repair

Run the identical workflow again. Require all applicable evidence:

- expected `deinit` probes fire;
- stale instance counts return to baseline;
- persistent Allocations generations stop growing;
- Leaks no longer reports the fixed allocation;
- settled footprint stabilizes after repeated use;
- cancellation, error, and early-dismissal paths also clean up.

Enable Zombies only in a separate run when diagnosing use-after-free. Zombies deliberately keep deallocated objects resident and must not be used to validate leak or footprint fixes.
