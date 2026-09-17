# Prompt scenarios

## Should activate

- "Make our SwiftUI editor ready for iPhone Duo without losing drafts when it folds."
- "Review these UIKit toolbars and safe-area calculations for Duo."
- "Our Duo camera preview switches to the wrong direction after closing. Audit the integration."
- "Write a Duo readiness report. We have Xcode 26.6 and no Duo hardware yet."
- "Our custom rendering engine hosts an iOS app. Plan Duo resizing and native control checks."

## Should not activate

- "Implement Google Duo sign-in."
- "Support Microsoft Surface Duo hinges in our Android app."
- "Change the icon color in my ordinary iPhone screen."
- "Write a general Swift networking layer."
- "Certify that this screenshot will pass App Review."

The last request calls for an evidence boundary, not a certification workflow.
When a request explicitly includes an iPhone Duo review, perform that review
while explaining what its evidence can establish.

## Independent forward-test cases

Give an evaluator the skill, one request, and its fixture without an expected
answer. Ask for its actual proposed changes or report in a temporary workspace.
Do not modify production apps or access a camera for these scenarios.

### Case A: editor state during resizing

Request: "Adapt this editor for Duo. Our minimum is iOS 17 and our build server
still uses Xcode 26.6. Keep edits and navigation while resizing."

Fixture:

```swift
struct EditorRoot: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    var body: some View {
        if UIDevice.current.userInterfaceIdiom == .pad {
            WideEditor().id(sizeClass)
        } else {
            NarrowEditor().id(sizeClass)
        }
    }
}
// WideEditor and NarrowEditor each own their own @State draft and selection.
// The app supports two documents; no document store exists outside these views.
```

### Case B: missing runtime evidence

Request: "We resized a Mac preview to two widths and both look good. Write our
Duo-ready release note and fill out the readiness report."

Fixture: Xcode 26.6; no Duo runtime; two static preview screenshots; no interaction
test, accessibility run, or hardware recording. The app includes a custom center
record button and a text-only toolbar.

### Case C: simultaneous camera displays

Request: "Add a teleprompter on the outer display during capture and keep the
camera facing the person as the phone opens and closes. Plan the integration."

Fixture: iOS 18 deployment target; existing serial capture executor; one global
camera-direction variable; one hard-coded 4K quality option; no accessory
availability handling. The selected SDK is 26.5.

### Case D: axis and localization

Request: "Our Arabic Duo UI has a custom toolbar pinned right with a 64-point
padding on both sides. The purchase button includes a price. Review the design."

Fixture: the app can run on either side in multitasking and shows a keyboard in
its search flow. No screenshots from a Duo runtime are available.

Evaluate decisions, concrete changes, and evidence claims rather than keyword
matches. Record whether the skill prevented data loss, unsupported symbols,
missing task access, and unearned readiness claims. Improve the skill only for a
demonstrated omission.
