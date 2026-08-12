# iOS Animation Graphics Skill

Use this skill for accessible SwiftUI animation, Canvas drawing, Core Animation bridges, and Lottie playback.

## Minimums vary by technique

- Canvas and TimelineView: iOS 15 / macOS 12.
- Matched geometry: iOS 14 / macOS 11.
- PhaseAnimator, KeyframeAnimator, and initial symbol effects: iOS 17 / macOS 14.
- Selected navigation and UIKit/AppKit animation bridges: iOS 18 / macOS 15.
- Native Lottie SwiftUI view: Lottie 4.3+. Pin a version and follow its package manifest; Lottie 4.6 requires Xcode 16 / Swift 6.

Always state the minimum for the chosen implementation and gate newer alternatives.

## Examples

- `example_canvas_waveform.swift`: TimelineView-driven Canvas animation with a static Reduce Motion result.
- `example_gradient_border.swift`: layer geometry updated after layout, with idempotent playback.
- `example_lottie_animation.swift`: declarative playback without type-name collisions.

Every looping or autoplaying effect needs a Reduce Motion policy and a lifecycle stop condition. Profile animation on physical supported hardware when performance matters.

Resources: [SwiftUI animation](https://developer.apple.com/documentation/swiftui/animation), [Canvas](https://developer.apple.com/documentation/swiftui/canvas), [TimelineView](https://developer.apple.com/documentation/swiftui/timelineview), and [Lottie iOS](https://github.com/airbnb/lottie-ios).
