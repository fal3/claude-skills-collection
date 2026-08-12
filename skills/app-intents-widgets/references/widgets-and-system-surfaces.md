# Widgets and system-surface selection

## Contents

1. Surface decision
2. Timeline widgets
3. Relevance
4. Controls
5. Live Activities
6. Shared data and testing

## 1. Surface decision

| Need | Use | Avoid |
|---|---|---|
| Glance at forecast/status at useful times | Timeline widget | Polling from the view |
| Choose which project a widget shows | `AppIntentConfiguration` | Hard-coded global selection |
| Complete a task from a widget | `Button(intent:)` | Ordinary SwiftUI action closure |
| Toggle a fast system-level state | Control Widget | A full information dashboard |
| Track one delivery/game/workout until completion | Live Activity | An indefinite status widget |
| Invoke an action by voice/automation | App Intent/App Shortcut | Adding a widget solely for discovery |

## 2. Timeline widgets

Treat each `TimelineEntry` as an immutable snapshot. The system displays entries at their dates; entries do not refetch data. A provider invocation creates a new timeline, and WidgetKit controls when reload requests are granted.

Provider requirements:

- Return a fast placeholder with no protected/user-specific content.
- Return a representative gallery snapshot, respecting preview context.
- Keep placeholders generic and apply `.privacySensitive()` or redacted alternatives to private rendered values where the supported surface honors them.
- Load/cache data in the provider or main app, not in `View.body`.
- Generate chronological entries and choose `.atEnd`, `.after(date)`, or `.never` from actual data semantics.
- Avoid requesting cosmetic/high-frequency reloads; scheduling budgets are system-controlled and not an exact timer contract.
- Keep the entry small and Sendable-friendly; precompute formatting and derived values.

Interactive controls in a widget use App Intents. A static widget can still be interactive; `AppIntentConfiguration` is for user configuration, not a prerequisite for buttons. Persist the mutation through shared/domain services so the next timeline reflects it.

## 3. Relevance

Add relevance only when a real contextual signal predicts usefulness—for example a travel widget near a destination, a routine during a time window, or a Smart Stack item during an active mode. Use only attributes supported by the deployment SDK and platform, and provide normal widget behavior when the system ignores relevance.

Do not assign maximum relevance permanently or fabricate context to force promotion. Test overlapping widgets and stale contexts so one feature does not crowd out more useful system content.

## 4. Controls

Use a Control Widget on iOS 18+ for a discrete button or boolean state that users expect to act quickly from Control Center, Lock Screen, or an action surface.

- Use an async value provider when state must be loaded.
- Provide an accurate, safe preview/fallback value.
- Make the intent idempotent and report failure clearly.
- Keep network/device work outside the rendering closure.
- Preserve an in-app/App Intent fallback on earlier OS versions.

Do not use a control for a multistep form, large content, or a mutation requiring extensive confirmation UI.

## 5. Live Activities

Use ActivityKit only when the content represents an ongoing event with:

- a clear start;
- compact static attributes;
- changing `ContentState`;
- a stale policy;
- an explicit completion/end path.

Examples include a delivery, ride, workout, game, flight, or timer. Static news, generic app status, or indefinite monitoring belongs in a widget/notification/app instead.

Live Activity rendering lives in the widget extension, but lifecycle updates come from the app or ActivityKit push path. Keep state payloads minimal, check authorization, and always end the activity. Provide a normal widget, notification, or in-app status fallback for unsupported devices/settings.

## 6. Shared data and testing

Use one App Group identifier in both entitlements. Verify both processes resolve the group container. Version shared snapshots and handle corruption/missing data without crashing.

Test:

- Placeholder, snapshot, and timeline logic independently.
- Every declared family, Dynamic Type, privacy/redaction, light/dark/accented rendering.
- Offline/missing/stale shared data.
- App writes followed by a meaningful reload request.
- Multiple widget instances with different configurations.
- Actual-device refresh behavior; previews prove layout only.
- Control state failures and stable fallback.
- Live Activity disabled, stale, update, and end paths if one is shipped.
