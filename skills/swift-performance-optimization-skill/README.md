# Swift Performance Optimization Skill

Evidence-driven performance guidance for CPU, memory, launch, SwiftUI updates, animation hitches, images, energy, and concurrency.

## When it applies

Use it for a measured performance symptom, a profiling plan, or a regression test. Do not use it for speculative micro-optimization or an unrelated functional bug.

## Compatibility

Examples use Xcode 16, Swift 6 strict concurrency, and iOS 17. Guidance that uses newer APIs must state availability. OS 27-cycle features are beta relative to stable Xcode 26.6 and are excluded unless explicitly requested and gated.

## Contents

- [Skill guidance](SKILL.md)
- [Stable list identity](examples/example_list_optimization.swift)
- [Lifecycle-safe periodic work](examples/example_memory_management.swift)
- [Image downsampling and reusable cells](examples/example_image_loading.swift)
- [Prompt scenarios](examples/prompts.md)

## Validation principle

Measure a repeatable Release-build scenario on representative hardware, save the baseline, make one change, and compare the same scenario. Code inspection can form a hypothesis; it cannot establish a performance win.

## Official resources

- [Instruments](https://developer.apple.com/documentation/xcode/instruments)
- [Improving your app's performance](https://developer.apple.com/documentation/xcode/improving-your-app-s-performance)
- [MetricKit](https://developer.apple.com/documentation/metrickit)
