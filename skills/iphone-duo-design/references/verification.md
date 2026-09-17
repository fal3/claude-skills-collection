# Verification matrix

This is a proposed engineering test plan. It does not describe tests already run
or requirements certified by Apple. Select rows that apply to the changed flow,
record the environment, and include a reproduction for every failure.

## Establish what the environment can prove

| Environment | Useful evidence | What remains unproved |
| --- | --- | --- |
| Source review and compiler | State ownership, signatures, availability, build gates | Runtime layout and interaction |
| Previews and existing simulators | Narrow/wide fit, text scaling, ordinary navigation | Duo bar placement, reserved regions, fold transitions |
| Duo simulator in a supported Xcode/Device Hub | Documented poses, transitions, multitasking, system controls available in that runtime | Physical reach, camera characteristics, hardware sensor behavior |
| Physical Duo | Touch around the fold, real cameras, display transfer, performance during transitions | App Review approval or blanket accessibility compliance |

Check the current runtime inventory. If Duo is absent, complete baseline layout
work and mark the corresponding rows blocked. A screenshot in a manually sized
window is not a Duo simulator run.

## Core transition coverage

Start with a representative document or active task, then move through the
configuration. Checking a freshly launched screen in each pose misses state loss.

| Case | Exercise | Observe |
| --- | --- | --- |
| Outer display | Portrait and landscape, then type in a field | Reachable actions, unobscured text, usable keyboard and overflow |
| Open inner display | Landscape and portrait, expand/collapse navigation | Same selected item, hierarchy, draft, and primary actions |
| Partial fold | Book-like and tabletop use, including contextual presentation | Important controls avoid awkward placement; content remains understandable |
| Repeat transitions | Open, partially fold, rotate, close during editing | No reset, duplicate task, lost focus, or unexpected dismissal |
| Multitasking | Place the app on either side; change available space | Each inset respected independently; no overlap or fixed-width clipping |
| Presentation | Sheet, alert, menu, popover, inspector if present | Visible confirmation and cancel/back route; correct anchor and action scope |
| System competition | Keyboard, Live Activity/status changes, PiP where relevant | Required actions remain available even when bars compress |
| Baseline devices | Existing supported iPhone and iPad configurations | No regression from new gates, layout changes, or unavailable capabilities |

For games or custom canvases, add hit-testing after every transform, readable
HUD text, camera/viewport framing, and input coordinates. Inspect letterboxing
decisions separately from the layout of native controls.

## Accessibility and localization

These checks apply to the app, including its custom controls. They are not
Duo-specific API claims. Use Apple's [accessibility HIG](https://developer.apple.com/design/human-interface-guidelines/accessibility)
and the project's supported interaction modes as the review baseline.

| Configuration | Evidence to collect |
| --- | --- |
| Largest supported Dynamic Type and accessibility sizes | Required content and actions remain readable without horizontal clipping |
| VoiceOver before and after a transition | Logical reading order, meaningful names and values, sensible focus, usable dismiss actions |
| Voice Control and Switch Control where supported | Every essential task remains reachable without a precise fold gesture |
| Reduce Motion | Layout remains understandable; optional hinge effects have a usable alternative |
| Reduce Transparency, increased contrast, light/dark | Text and custom toolbar content remain legible in all tested presentations |
| RTL and long translations | Correct content direction, unclipped labels, preserved hardware-relative system bars |
| Hardware keyboard where supported | Focus order, editing, modal escape, and shortcuts survive resizing |

Use touch targets of at least 44 by 44 points as the iOS design review baseline.
Check actual hit areas, not just icon dimensions. Measure contrast where needed;
an attractive screenshot is insufficient accessibility evidence.

## Optional capabilities

Run these only when the app uses the capability.

| Capability | Transition and expected invariant |
| --- | --- |
| New scene | Request while available, then change configuration; failure keeps current content usable |
| Multiple scenes | Edit or navigate independently; shared document changes follow the chosen conflict policy |
| Scene accessory | Toggle availability, close the device, leave camera UI; remove auxiliary content and keep the main task usable |
| Capture | Open/close, change facing direction, interrupt/resume; correct camera, orientation, mirroring, output, and recording status |
| Camera permissions | Deny or restrict access; visible recovery path without a phantom active preview |
| Hinge effect | Absent hinge, endpoint states, Reduce Motion; return to baseline and retain an alternative input |
| Background/termination | Save, background, terminate, restore; distinguish persisted state from in-memory continuity |

## Evidence discipline

Record commit, build SDK, deployment target, runtime/device model, input sequence,
result, and artifact location. Screenshots document a layout; screen recordings
and interaction notes document transitions. Logs can establish task ownership
and cancellation, but cannot prove touch comfort or visual legibility.

Use the [readiness report](readiness-report.md). A blocked row is not a pass.
Do not write "all poses tested" unless the report identifies those poses and
their actual runtime evidence.
