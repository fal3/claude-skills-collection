# iPhone Duo design and readiness

A portable skill for making an existing iOS app work well as iPhone Duo opens,
closes, folds, changes orientation, or shares its display with another app.
It covers SwiftUI and UIKit design decisions, with guidance for custom rendering
and embedded cross-platform UI. The skill does not depend on a particular agent,
IDE, MCP server, or command syntax.

Ask your assistant to use `iphone-duo-design`, or attach [SKILL.md](SKILL.md) in
hosts without skill discovery. A representative request is:

> Review our editor for iPhone Duo. Keep our current deployment target, fix
> adaptive-layout issues we can validate now, and report what still needs the
> Duo SDK or hardware.

## What is included

- [Layout and controls](references/layout-and-controls.md): safe areas, vertical
  bars, overflow, fold avoidance, and choice of layout container.
- [Continuity, scenes, and camera](references/continuity-scenes-camera.md): state
  ownership, scene availability, capture direction, and secondary displays.
- [Versions and sources](references/versions-and-sources.md): Apple source
  links, verified API availability, and older-SDK boundaries.
- [Verification matrix](references/verification.md) and
  [readiness report](references/readiness-report.md).
- [Adaptive editor](examples/AdaptiveEditor.swift) and
  [behavioral scenarios](examples/prompts.md).

## Version and validation limits

The example requires Swift 5.9, Xcode 15, and iOS 17 or later. It uses established
SwiftUI and Observation APIs. It was typechecked for the iOS device and simulator
with Xcode 26.6 and SDK 26.5 in Swift 6 mode on September 17, 2026. This establishes
source compatibility with those configurations; no runtime UI test is claimed.

Apple's Duo landing page listed Xcode 27.1 beta as coming later in September at
the source check. Some Duo API reference pages were already available and marked
beta. The package includes guidance for those APIs but no claimed compile-tested
Duo implementation. Refresh the sources before using them.

The example keeps edits in memory for one scene's lifetime. It does not persist
documents across process termination, synchronize multiple windows, or implement
camera capture. The report template makes those separate validation decisions
visible. Design readiness is not Apple certification or App Review approval.
