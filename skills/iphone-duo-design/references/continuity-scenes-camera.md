# Continuity, scenes, and camera

## State ownership

Engineering recommendations:

- Store document edits and running tasks outside compact/regular view branches.
  Keep stable document identifiers and one owner for each operation. If a view
  reappears during resizing, its `.task` must not submit the same operation twice.
- Keep selection, navigation, sheet identity, search, and scroll anchors scoped
  to the appropriate scene. Where the UI must change, preserve the user's task
  and a sensible focus target.
- Define separate persistence for process termination. In-memory state surviving
  a resize does not prove restoration after the app is killed.
- For shared documents, choose how simultaneous edits reconcile. Do not put
  active-window state in a shared singleton just to make two windows agree.
- Test rapid transitions during saving, recording, playback, and authentication.
  Reconfiguration should be cancelable and idempotent where the operation permits.

The [editor example](../examples/AdaptiveEditor.swift) demonstrates only the first
ownership boundary. Add storage and restoration appropriate to the actual app.

## Scenes, displays, and hinge effects

Apple documents multiple app scenes on the inner display, with new-scene creation
unavailable on the outer display. Requests can fail as availability changes.
Scene accessories are dynamically available; a camera capture accessory requires
an active capture session and full-screen inner-display UI. Attach it to the
camera view's lifetime. Observe availability rather than caching a device-wide
capability. Hinge observations support effects and interactions; use region and
arrangement APIs for layout. A non-hinged device produces no hinge, so restore
an effect's normal value when the input is absent or no longer applies.
[Scenes talk](https://developer.apple.com/videos/play/tech-talks/111464/)

Review actions:

- Handle scene-request errors and a capability change between button display
  and activation. Keep the document accessible in the current scene.
- Read screen properties from the associated scene only when the task requires
  them; do not treat screen order or one global key window as stable identity.
- Treat a second-display experience as an optional presentation. Keep primary
  controls usable when it disappears, disconnects, or never becomes available.
- Decide which data the outward-facing display may show. For a teleprompter,
  present the selected script, not private notes or incidental notifications.
- Offer another way to perform any action driven by a hinge effect. Respect
  Reduce Motion and stop work when the effect is inactive.

## Capture decisions

Apple's virtual front camera switches physical front cameras as the device opens
and closes, exposing their shared capabilities. Direct physical-camera selection
offers additional capabilities but makes the app responsible for switching.
The AVKit direction coordinator reports camera direction relative to its view;
two displays need separate coordinators. Its main-actor callback supplies a
sendable device descriptor for camera execution away from the UI actor. A fixed
`.front` position alone cannot say whether a camera faces the viewer. Review
preview mirroring when direction changes, use the rotation coordinator across
display changes, and choose preview gravity and aspect ratio deliberately.
[Camera talk](https://developer.apple.com/videos/play/tech-talks/111465/)

Review actions:

- Prefer the virtual path unless the product needs capabilities it cannot supply.
  Query supported formats, frame rates, and depth at runtime. Do not offer a
  quality setting based only on a marketing device name.
- Serialize session configuration on the camera executor. Avoid blocking capture
  work inside a main-actor direction callback or racing a second reconfiguration.
- Give an interrupted recording an explicit outcome. Verify the resulting file,
  preview orientation, and saved-image orientation independently.
- Check permission denial, interruption, unavailable cameras, and accessory loss.
  A frozen preview must not imply that recording is still working.
- Evaluate active inner-camera occlusion alongside preview controls. A correct
  image pipeline does not establish readable controls or accessible focus.

Consult the [verified availability table](versions-and-sources.md) before coding.
The camera discussion is an integration plan, not a drop-in capture implementation.
