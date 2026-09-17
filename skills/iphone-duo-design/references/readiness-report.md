# iPhone Duo readiness report

Copy this template into the app's review artifacts and replace the bracketed
fields. Remove irrelevant rows with a short reason. This template contains no
test results.

## Scope and environment

- App, commit, and reviewed flow: [identify]
- UI framework and rendering layers: [identify]
- Minimum OS and Swift language mode: [actual project settings]
- Xcode and SDK: [actual tool versions]
- Simulator/runtime or physical device: [identify, or unavailable]
- Apple sources checked on: [date and links]
- Requested outcome: [design review, implementation, or release evidence]

## Findings and changes

| Impact | Flow and reproduction | Evidence or source | Change and fallback | Status |
| --- | --- | --- | --- | --- |
| [data loss / blocked task / usability / polish] | [specific steps] | [artifact or official link] | [implemented behavior] | [verified / failed / blocked / not applicable] |

## Verification

| Case | Environment and sequence | Result | Evidence / remaining check |
| --- | --- | --- | --- |
| Existing supported devices | [details] | [status] | [link or gap] |
| Outer portrait and landscape | [details] | [status] | [link or gap] |
| Inner portrait and landscape | [details] | [status] | [link or gap] |
| Partial fold and repeated transitions | [details] | [status] | [link or gap] |
| Left/right multitasking and keyboard | [details] | [status] | [link or gap] |
| Overflow and modal escape routes | [details] | [status] | [link or gap] |
| Accessibility and localization | [settings and interaction mode] | [status] | [link or gap] |
| Scenes, accessories, and capture | [applicable capabilities] | [status] | [link or gap] |
| Persistence and restoration | [details] | [status] | [link or gap] |

## Availability and remaining work

- New APIs and official minimum versions: [list exact members used]
- Older-SDK exclusion and runtime gate: [implementation location]
- Fallback behavior and verification: [describe]
- Blocked checks: [what is missing and the exact next action]
- Remaining failures: [user impact and owner]

## Readiness statement

[Describe only the validated scope. Name any SDK, simulator, device, or
accessibility evidence still missing. Do not claim Apple certification or App
Review approval.]
