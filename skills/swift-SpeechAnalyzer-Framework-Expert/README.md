# SpeechAnalyzer Framework Expert

Use this skill for Apple’s stable SpeechAnalyzer-generation transcription APIs.

## Baseline

- Xcode 26 or newer.
- iOS 26, macOS 26, visionOS 26, or tvOS 26 for SpeechAnalyzer and SpeechTranscriber.
- No watchOS support.
- DictationTranscriber is unavailable on tvOS and watchOS.
- Live microphone example: iOS 26 only.

The guidance is validated against Xcode 26.6 and the iOS 26.5 SDK. APIs that appear only in a later beta SDK belong in a beta-only source path plus runtime availability gates; stable Xcode cannot compile unknown symbols hidden only by `#available`. Keep the stable 26 path.

## Correct API model

1. Check device availability and resolve an equivalent supported locale.
2. Reserve the locale through `AssetInventory`.
3. Install required assets.
4. Guard the optional compatible audio format.
5. Analyze input and consume `SpeechTranscriber.Result` values.
6. Read `result.text` (`AttributedString`) and `result.isFinal`.
7. Finalize or cancel analysis, await result work, and release reservations created by the feature.

`AssetInstallationRequest.progress` is Foundation `Progress`, not an async sequence. The stable SDK has no `SpeechTranscriber.allocate(locale:)`, `SpeechTranscriptionResult`, or `result.transcription` API.

## Included examples

- `basic_setup.swift`: scoped preparation and reservation ownership.
- `locale_manager.swift`: locale equivalence, install progress, and release.
- `error_handling.swift`: typed failures and result accumulation.
- `file_transcription.swift`: structured finite-file analysis.
- `live_transcription.swift` + `buffer_converter.swift`: iOS permissions, audio session, capture, conversion, result task, and teardown.

Live iOS apps must provide `NSSpeechRecognitionUsageDescription` and `NSMicrophoneUsageDescription`. Coordinate `AVAudioSession` centrally if the app also plays audio or records elsewhere.

Resources: [SpeechAnalyzer](https://developer.apple.com/documentation/speech/speechanalyzer), [SpeechTranscriber](https://developer.apple.com/documentation/speech/speechtranscriber), and [AssetInventory](https://developer.apple.com/documentation/speech/assetinventory).
