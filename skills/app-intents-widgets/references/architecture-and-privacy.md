# Architecture, execution, and privacy

## Contents

1. Layering
2. Entities and queries
3. Dependencies and shared state
4. Execution and confirmation
5. Deep links, handoff, and fallback
6. Test matrix

## 1. Layering

Keep the system adapter thin:

```text
AppIntent / EntityQuery / Widget intent
                ↓
       Sendable use-case protocol
                ↓
     actor/service + persistence client
```

The adapter owns App Intents metadata, parameters, dialogs, and result conversion. The use case owns authorization and business rules. The repository owns persistence/networking. This structure lets the app, shortcut, widget, control, and tests invoke the same capability without sharing UI state.

Avoid:

- Calling a view model or navigation singleton from a background intent.
- Opening a new database independently in every `perform()` call.
- Returning managed objects or mutable model classes across isolation/process boundaries.
- Putting business rules only in dialog or confirmation code.

## 2. Entities and queries

An `AppEntity` is a durable reference plus system-facing presentation:

- Choose an ID that survives relaunch and sync.
- Expose only fields needed for display, filtering, or downstream actions.
- Treat display representations and suggestions as potentially cached system metadata; use a product-approved safe alias when the real title is private.
- Resolve current data in `entities(for:)`; preserve input identifier order when it matters.
- Return a bounded list from `suggestedEntities()` based on recency/favorites/relevance.
- Implement `entities(matching:)` for meaningful search beyond suggestions.
- Handle deleted, inaccessible, and signed-out entities without crashing.

Use `AppEnum` for a fixed, localized set. If values come from user data or a server, use an entity/query instead.

App Shortcuts should cover a few frequent outcomes. Include `\(.applicationName)` in phrases, avoid near-duplicate phrasing, and verify discoverability on device.

## 3. Dependencies and shared state

Register a Sendable dependency early:

```swift
let store = ProjectStore()
AppDependencyManager.shared.add(dependency: store)
```

Then resolve it in an intent or query:

```swift
@Dependency private var store: ProjectStore
```

Register dependencies in each executable that can instantiate the adapter. Inject test dependencies with a dedicated manager or test bootstrap. Actors are a natural fit for mutable services because `AppDependency` requires a Sendable value.

App and widget processes cannot share the actor instance. For cross-process data:

- Configure the same App Group entitlement in app and extension.
- Use an App Group file, defaults suite, or carefully configured database.
- Define a Codable/versioned snapshot rather than sharing internal model layouts accidentally.
- Coordinate writes; assign one writer where possible.
- Treat data as stale and optional in the widget.
- Apply appropriate file protection and never put credentials in shared defaults.
- If an extension must authenticate to a backend, configure an explicit shared Keychain access group; keep the server authoritative and coordinate cross-process writes or use atomic replacement.

## 4. Execution and confirmation

Decide independently:

- **Authentication:** may the action run while locked or signed out?
- **Authorization:** may this account affect this entity now?
- **Confirmation:** should the user explicitly approve this invocation?
- **Foregrounding:** can it finish headlessly, or does it require UI?

`requiresAuthentication` allows the originating trusted device to satisfy authentication even when another device executes the code. Use `requiresLocalDeviceAuthentication` when the executing device itself must be unlocked—for example, because complete file protection guards required data. Neither policy proves the signed-in account may perform the action.

Validate parameters and current data immediately before mutation. Confirm destructive actions before committing. Make repeated invocation idempotent when Siri/Shortcuts retries could otherwise duplicate an order, upload, or message.

For iOS 26-only targets, use `supportedModes`. With an older deployment floor, retain and test the stable older execution declaration; protocol metadata is not ordinary branch code, so design compatibility intentionally.

Keep dialogs concise and non-sensitive. Avoid putting account balances, private titles, health information, or secrets into lock-screen-visible display representations unless the product deliberately permits it.

## 5. Deep links, handoff, and fallback

Define one routing contract used by the app and system surfaces:

```text
myapp://project/<stable-id>?action=review
```

- Parse and validate the route centrally.
- Ignore/deny unexpected actions and malformed IDs.
- Fetch current data after opening; do not trust route payload as authority.
- Fall back to the relevant list or signed-out screen if the entity is unavailable.
- Use universal links when the route also belongs on the web.
- Use `NSUserActivity` when current-content continuity or Handoff is the goal.

An intent that can finish in the background should do so. Offer an “open” continuation for optional detail. If foreground UI is mandatory, declare that mode rather than attempting to manipulate UI from a background execution.

## 6. Test matrix

Test the use case directly with fakes, then the adapter:

- Required/optional/default parameter combinations.
- ID resolution, suggestions, search, and deleted IDs.
- Authorized, unauthorized, locked, and signed-out states.
- Confirmation accepted, declined, and interrupted.
- Duplicate invocation and cancellation.
- Background completion and foreground continuation.
- Deep-link success, malformed route, missing entity, and unsupported feature.
- App and extension reading the same versioned App Group snapshot.
- Localization of titles, phrases, dialogs, enum/entity representations.

Finally test discovery in Shortcuts, Siri, Spotlight, widgets, controls, or Live Activities only for the surfaces the feature actually ships.
