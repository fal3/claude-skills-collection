# Versions and source evidence

Source check: September 17, 2026. Refresh before implementation. The local
validation toolchain was Xcode 26.6 (17F113), with iOS SDK 26.5. No iPhone Duo
runtime or physical-device validation was performed for this package.

## Release boundary

Apple's [Duo landing page](https://developer.apple.com/iphone-duo/) listed Xcode
27.1 beta and the app-preparation article as coming later that month. The
[preparation talk](https://developer.apple.com/videos/play/tech-talks/111461/)
describes rebuilding against the iOS 27.1 SDK to adopt the full display and new
bar behavior. An SDK's build-linked behavior and an app's minimum deployment
target are different settings. Do not raise the target merely to rebuild.

Inspect the actual environment before offering commands:

```sh
xcodebuild -version
xcrun swiftc --version
xcrun --sdk iphoneos --show-sdk-version
xcrun --sdk iphonesimulator --show-sdk-version
xcrun simctl list runtimes
```

Use the selected project's build settings for its deployment target and Swift
language mode. Do not infer them from the installed compiler version.

## Verified API availability

These rows reflect Apple's API metadata on the source-check date. They identify
API families; they do not substitute for checking the exact member signature.
All minimum versions below refer to iOS and iPadOS.

| API | Earliest version | Status at source check |
| --- | --- | --- |
| [NavigationSplitView](https://developer.apple.com/documentation/swiftui/navigationsplitview) | 16.0 | Established baseline |
| [AnyLayout](https://developer.apple.com/documentation/swiftui/anylayout) | 16.0 | Established baseline for preserving view identity when changing layout type |
| [ArrangementView](https://developer.apple.com/documentation/swiftui/arrangementview) | 27.1 | Beta; not locally compiled |
| [ReservedRegion](https://developer.apple.com/documentation/swiftui/reservedregion) | 27.1 | Beta; not locally compiled |
| [UIHingeInteraction](https://developer.apple.com/documentation/uikit/uihingeinteraction) | 27.1 | Beta; not locally compiled |
| [CameraCaptureAccessory](https://developer.apple.com/documentation/swiftui/cameracaptureaccessory) | 27.1 | Beta; not locally compiled |
| [AVCaptureDeviceDirectionCoordinator](https://developer.apple.com/documentation/avkit/avcapturedevicedirectioncoordinator) in AVKit | 27.1 | Beta; not locally compiled |
| [ToolbarItemVisibilityPriority](https://developer.apple.com/documentation/swiftui/toolbaritemvisibilitypriority) | 27.0 | Documented; not locally compiled |
| [ToolbarOverflowMenu](https://developer.apple.com/documentation/swiftui/toolbaroverflowmenu) | 27.0 | Documented; not locally compiled |
| [ToolbarVerticalCompressionBehavior](https://developer.apple.com/documentation/swiftui/toolbarverticalcompressionbehavior) | 27.1 | Beta; not locally compiled |

For example, put an implementation that uses `ArrangementView` in an
`@available(iOS 27.1, *)` declaration and select it with `if #available(iOS 27.1, *)`.
Keep the app's existing layout as the `else` branch. If older SDKs must still
build the project, exclude that implementation from those targets or use an
explicit build condition enabled only for SDKs that declare the symbols.
`#available`, a compiler version comparison, or `canImport(SwiftUI)` alone does
not solve an unknown-symbol error in an older SwiftUI SDK.

Use the same verified-version pattern for the other APIs. A fallback for scenes
keeps the current scene usable; a fallback for camera features keeps a supported
capture path. Do not guess a member name from a transcript or label an unbuilt
snippet production-ready.

## Official reading map

Read the relevant chapter instead of copying entire transcripts into context.

| Source | Useful chapters |
| --- | --- |
| [Design for iPhone Duo](https://developer.apple.com/videos/play/tech-talks/111460/) | 3:42 design adaptation; 5:07 controls; 8:36 sheets; 9:28 fold avoidance |
| [Prepare your app](https://developer.apple.com/videos/play/tech-talks/111461/) | 0:30 SDK adoption; 2:46 size classes; 3:57 screen assumptions; 6:06 safe areas |
| [Raise the bar](https://developer.apple.com/videos/play/tech-talks/111462/) | 2:00 opt-in; 5:56 toolbar content; 10:07 custom views; 11:40 overflow |
| [Adaptive layouts and poses](https://developer.apple.com/videos/play/tech-talks/111463/) | 2:26 displacement; 6:39 regions; 9:20 arrangements; 16:09 unsuitable containers |
| [Multiple displays and scenes](https://developer.apple.com/videos/play/tech-talks/111464/) | 2:35 hinge versus layout; 3:38 multiple scenes; 4:22 accessories |
| [Camera experience](https://developer.apple.com/videos/play/tech-talks/111465/) | 0:58 virtual front camera; 2:46 direction; 5:38 descriptors; 8:03 rotation |
| [Duo Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo) | Device poses, reserved regions, arrangement views, vertical controls |

Apple's documentation pages may require JavaScript. If necessary, fetch their
official DocC representation by replacing the page path with
`/tutorials/data/<page-path>.json`, for example
[Duo HIG data](https://developer.apple.com/tutorials/data/design/human-interface-guidelines/designing-for-iphone-duo.json).
Read `metadata.platforms` and declaration tokens for availability and signatures;
do not infer an API's absence from an empty HTML rendering.
