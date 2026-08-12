# Cross-Platform App Development Skill

Strategies for sharing Swift and SwiftUI product code across iOS, iPadOS, Mac Catalyst, macOS, watchOS, tvOS, and visionOS without flattening their different interaction models.

## When it applies

Use this skill when a product intentionally targets at least two Apple platforms. Do not activate it for a single-platform feature or for Flutter, React Native, Kotlin Multiplatform, or other non-Apple frameworks.

## Stable baseline

Examples use Xcode 15 and Swift 5.9 with iOS/iPadOS/Catalyst 17, macOS 14, watchOS 10, tvOS 17, and visionOS 1. Older deployments need explicit compatibility paths. OS 27-cycle features are beta relative to stable Xcode 26.6 and are excluded unless explicitly requested and gated.

## Contents

- [Skill guidance and target matrix](SKILL.md)
- [Adaptive layout](examples/example_adaptive_layout.swift)
- [Platform-specific branches](examples/example_platform_specific.swift)
- [Adaptive navigation](examples/example_adaptive_navigation.swift)
- [Prompt scenarios](examples/prompts.md)

## Validation

Typecheck and run each target at its stated minimum. Test the real input, focus, windowing, storage, background, and accessibility behavior of every platform; compiling a shared view on one simulator does not establish cross-platform readiness.

## Official resources

- [SwiftUI](https://developer.apple.com/documentation/swiftui/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [Mac Catalyst](https://developer.apple.com/mac-catalyst/)
- [visionOS](https://developer.apple.com/visionos/)
