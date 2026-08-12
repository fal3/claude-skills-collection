# Memory Leak Diagnosis Skill

Use this skill when a Swift object does not deallocate, memory grows across repeated workflows, a cache appears unbounded, or an app is terminated under memory pressure.

## Diagnostic model

1. Define the expected lifetime.
2. Reproduce a bounded lifecycle and add temporary `deinit` probes.
3. Follow incoming strong paths in Xcode Memory Graph.
4. Compare repeated generations in Instruments Allocations.
5. Use Leaks for unreachable allocations and VM Tracker for non-object footprint.
6. Fix the ownership/cancellation contract and repeat the same measurement.

Do not enable Zombies during leak or footprint measurement. Zombies are for use-after-free diagnosis and intentionally keep deallocated objects resident.

## Included material

- `examples/example_retain_cycle.swift`: correct stored-closure, delegate, bidirectional, value-container, and task-lifetime graphs.
- `examples/example_instruments_leaks.md`: repeatable Memory Graph, Allocations, Leaks, and verification steps.
- `examples/prompts.md`: representative requests.

Weak is appropriate when the referenced object may die first. Unowned is appropriate only when a real lifetime invariant guarantees the object is alive at every access. Value types can still carry closures or references that participate in a cycle.

Resources: [Automatic Reference Counting](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/automaticreferencecounting/), [Gathering information about memory use](https://developer.apple.com/documentation/xcode/gathering-information-about-memory-use), and [Making changes to reduce memory use](https://developer.apple.com/documentation/xcode/making-changes-to-reduce-memory-use).
