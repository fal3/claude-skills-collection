# SwiftUI Programming Skill

Practical SwiftUI guidance for view composition, state ownership, navigation, adaptive layout, toolbars, SF Symbols, accessibility, and measured performance.

## When it applies

Use it for SwiftUI-specific implementation or review. Do not use it for UIKit/AppKit-only work or general Swift questions without a SwiftUI surface.

## Compatibility

Primary examples target Xcode 15, Swift 5.9, iOS/iPadOS 17, and macOS 14. The skill also explains supported compatibility paths for earlier deployments, including `NavigationView` and `ObservableObject`; newer APIs must be gated at their real availability.

OS 27-cycle APIs are considered beta relative to stable Xcode 26.6 and are included only when explicitly requested with labels, fallbacks, and availability checks.

## Contents

- [Skill guidance](SKILL.md)
- [State-driven toggle](examples/example_toggle.swift)
- [Navigation and toolbar example](examples/example_toolbar.swift)
- [Prompt scenarios](examples/prompts.md)

## Validation expectations

Compile copied code at the oldest declared deployment target. Test Dynamic Type accessibility sizes, VoiceOver, light/dark appearance, compact and wide layouts, and the input methods of every supported platform.

## Official resources

- [SwiftUI documentation](https://developer.apple.com/documentation/swiftui/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
