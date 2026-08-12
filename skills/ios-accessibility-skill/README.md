# iOS Accessibility Skill

Implementation and review guidance for VoiceOver, Voice Control, Switch Control, Full Keyboard Access, Dynamic Type, visual and motion settings, media alternatives, cognitive accessibility, and Assistive Access.

## When it applies

Use it for iOS/iPadOS accessibility work. Do not activate it for generic visual styling with no accessibility question.

## Compatibility

Examples use Xcode 15, Swift 5.9, and iOS/iPadOS 17. The skill calls out newer availability: the Assistive Access environment value starts at iOS 18, while the dedicated SwiftUI scene is an iOS 26 API. OS 27-cycle APIs are beta unless a user explicitly requests them.

## Contents

- [Skill guidance](SKILL.md)
- [VoiceOver example](examples/example_voiceover.swift)
- [Dynamic Type example](examples/example_dynamic_type.swift)
- [Prompt scenarios](examples/prompts.md)

## Validation

Use Accessibility Inspector as a starting point, then test important flows with the actual assistive technologies on device. Automated checks do not validate reading order, comprehensibility, focus recovery, or task completion.

## Official resources

- [Accessibility for Apple platforms](https://developer.apple.com/accessibility/)
- [SwiftUI accessibility](https://developer.apple.com/documentation/swiftui/accessibility)
- [Human Interface Guidelines: Accessibility](https://developer.apple.com/design/human-interface-guidelines/accessibility)
