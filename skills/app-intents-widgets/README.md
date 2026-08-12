# App Intents and Widgets

Use this skill to expose app capabilities through stable App Intents and to select, build, and verify the appropriate WidgetKit system surface.

## Coverage

- `AppIntent`, `AppEntity`, `AppEnum`, queries, and `AppShortcutsProvider`
- Thin intent adapters, Sendable dependency injection, and App Group data sharing
- Authentication, authorization, confirmation, and lock-screen privacy
- Timeline widgets, relevance, interactive widgets, Control Widgets, and Live Activity selection
- Deep links, `NSUserActivity` handoff, and safe fallbacks
- Target/deployment discovery and cross-target verification

Stable Xcode 26.6 APIs are the baseline. OS 27-cycle App Intents additions are beta, require an explicit beta toolchain and availability/build gates, and must retain a stable fallback.

## Contents

- [Skill guidance](SKILL.md)
- [Architecture and privacy](references/architecture-and-privacy.md)
- [Widgets and system surfaces](references/widgets-and-system-surfaces.md)
- [OS 27 beta boundary](references/os-27-beta-boundary.md)
- [Compile-checked App Intents example](examples/AppIntentsExample.swift)
- [Compile-checked iOS 17+ WidgetKit example](examples/WidgetTimelineExample.swift)
- [Prompt scenarios](examples/prompts.md)

## Validation expectation

Compile shared declarations in each app/extension target, test domain behavior with injected fakes, and verify discovery, routes, widget families, missing shared data, and supported system surfaces on physical devices.
