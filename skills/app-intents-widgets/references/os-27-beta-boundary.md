# OS 27 beta boundary and stable fallbacks

The baseline for this skill is stable Xcode 26.6. APIs first appearing in the OS 27 development cycle are beta and are not validated by the stable compiled examples.

## Rules for an explicit beta request

1. Confirm the user is using an Xcode 27 beta and record the exact build/SDK.
2. Look up symbols in that installed beta SDK or official beta documentation.
3. Label every 27-only declaration and behavior as beta.
4. Put beta-only declarations in a file/target excluded from stable builds when the stable SDK cannot parse or resolve them.
5. Add runtime availability gates where the beta SDK supports deployment to older OS versions.
6. Keep and test a stable AppIntent/AppEntity/query/widget path.
7. Re-typecheck on every beta because names, conformances, availability, and generated metadata can change.

## App Intents beta examples

OS 27-cycle schema-adoption macros and App Intents testing facilities are beta relative to this baseline. Do not claim their spellings or behavior from memory, and do not replace a stable `AppIntent`, `AppEntity`, `EntityQuery`, or direct fake-driven test until the installed beta SDK confirms the API.

`UndoableIntent` is a stable iOS 26 API, not an OS 27 beta API; it still needs an iOS 16-25 fallback when the deployment floor is lower. Explicit execution-target selection is absent from stable Xcode 26.6, so treat any beta form as unverified until the installed Xcode 27 beta confirms the exact symbols.

Stable fallbacks:

- Keep ordinary `AppIntent`/`AppEntity`/`AppEnum` conformances and explicit queries.
- Keep `AppShortcutsProvider` for zero-setup discovery.
- Test domain services directly and call `perform()` with injected fakes where practical.
- Preserve URL/NSUserActivity routing when a beta system continuation is unavailable.

`if #available(iOS 27, *)` handles runtime selection only after code compiles with an SDK that declares the symbol. It cannot make a stable Xcode 26 compiler accept an unknown API.
