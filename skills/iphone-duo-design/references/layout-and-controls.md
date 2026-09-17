# Layout and controls

The Apple facts below are a September 17, 2026 snapshot. Review actions are this
skill's recommendations for applying them to a particular app.

## Space and hierarchy

Apple describes a consistent app across displays, with extra space exposing
more of the same hierarchy. System sheets, alerts, menus, and other controls
adapt around a partial fold; continuous scrolling content can cross that region.
An immersive background may fill the display while interactive foreground
content stays inset. [Design talk](https://developer.apple.com/videos/play/tech-talks/111460/)

The outer display uses compact horizontal size class; its vertical size class
is regular in portrait and compact in landscape. The full inner display uses regular size classes.
Multitasking still changes the app's available space. Idiom and interface
orientation are unsuitable layout selectors. Read local geometry, traits, and
scene bounds instead of `UIScreen.main`. Safe areas and layout margins can be
asymmetric. By default, the inner display does not honor the app's supported
interface orientations. `UIRequiresFullScreen` preserves orientation support
through scaling there, including in Split View, but does not prevent resizing
when the phone opens or closes. Test the app's actual configuration.
[Preparation talk](https://developer.apple.com/videos/play/tech-talks/111461/)

Review actions:

- Find fixed content widths, screen-size caches, idiom switches, forced column
  counts, and symmetric padding calculations. Replace the specific assumption
  that breaks the flow; do not remove legitimate content limits indiscriminately.
- Use size class for broad structure and measured container space for detailed
  fit. Large text and localization can require a simpler layout at the same width.
- Compare the selected document, route, and available actions before and after
  collapse. A regular width must not unlock essential functionality.

## Bars and overflow

Apple's standard navigation containers manage the new bar placement. Creating
standalone UIKit bars does not receive the same adaptation. Detail-column items
participate in the vertical region; controls for other columns remain associated
with their content. The system chooses representations from item titles and
symbols. Text-only or wide controls may stay horizontal. Use semantic item
groups, keep a meaningful title for overflow, and prioritize frequently used
actions or status indicators. Consolidate app overflow into the system menu;
reserve the ellipsis for that purpose. Keyboard accessories remain attached to
the keyboard. [Bar talk](https://developer.apple.com/videos/play/tech-talks/111462/)

The HIG describes vertical bars on the outer display and inner landscape, with
horizontal bars in inner portrait. In Split View, controls may occupy the app's
left or right outer edge. Their hardware-relative edge does not mirror for RTL.
Use each safe-area edge independently; do not force a right-side gutter or mirror
the bar yourself. [Duo HIG](https://developer.apple.com/design/human-interface-guidelines/designing-for-iphone-duo)

Review actions:

- Test a crowded toolbar with the keyboard and system overlays present. Confirm
  its action labels, ordering, enabled state, and access through overflow.
- Distinguish a document action from a list action. Moving both into the same
  edge bar can make their scope unclear.
- Check custom controls in both bar axes, including Reduce Transparency. Preserve
  meaningful text such as a price instead of replacing it with an ambiguous icon.
- Keep default placement unless a specific flow benefits from an exception.
  Document that reason and validate both presentations.

## Fold-aware custom content

Apple distinguishes division regions, such as an active fold, from occlusion
regions, such as an active inner camera. Region queries use local coordinates;
inactive regions can be requested when their presence matters. Displace related
elements together with minimal movement. Avoid relocating continuous scrolling
content. Use arrangements for two related content views: split when both must
remain visible, overlay when foreground/background layering fits the task.
Keep navigation outside arrangements and avoid placing arrangements inside
`List` or `ScrollView`. Hinge sensor data is not the layout contract.
[Adaptive layout talk](https://developer.apple.com/videos/play/tech-talks/111463/)

Review actions:

- Use standard containers before writing custom displacement. For a custom
  canvas, evaluate controls and critical content separately from its background.
- Query regions in the receiving view's coordinate space, update when geometry
  changes, and discard cached screen coordinates. Never hard-code fold width.
- Check a centered primary button, a contextual menu, and a grid item during a
  partial fold. Maintain the relationship between a control and its subject.
- Keep controls reachable when an optional secondary pane collapses. Provide
  another route to its content if the arrangement hides it.

Read [version gates](versions-and-sources.md) before using reserved-region,
arrangement, or newer toolbar symbols. Existing-SDK work can improve sizing,
semantic controls, and state ownership while those integrations await testing.
