# SpeechAnalyzer Framework Expert

This skill provides comprehensive expertise in implementing Apple's modern Speech framework for macOS 26+ and iOS 26+. It covers `SpeechAnalyzer`, `SpeechTranscriber`, and on-device speech-to-text transcription with best practices for real-time audio processing.

## Activation

This skill activates automatically for queries related to:
- Speech framework (macOS 26+, iOS 26+)
- SpeechAnalyzer and SpeechTranscriber APIs
- On-device speech recognition and transcription
- Audio buffer processing for speech-to-text
- Migrating from WhisperKit or SFSpeechRecognizer
- Real-time microphone transcription
- Locale management and language model downloads

## Key Features

### Performance
- **2.2x faster** than Whisper Large V3 Turbo
- **Out-of-process execution** eliminates memory limits in your app
- **Automatic system updates** without app redeployment

### Language Support
- 10+ languages supported including:
  - English, Spanish, French, German, Italian
  - Japanese, Korean, Portuguese, Russian, Chinese

### Capabilities
- Real-time transcription with volatile results
- Final transcription segments
- Word-level timing information
- On-device processing for privacy
- Automatic model management and downloads

## Setup

To use this skill effectively:

1. **System Requirements**
   - macOS 26+ or iOS 26+
   - Xcode 16+ for development
   - Device running latest OS for on-device transcription

2. **Framework Import**
   ```swift
   import Speech
   ```

3. **Privacy Permissions**
   - Add `NSSpeechRecognitionUsageDescription` to Info.plist
   - Add `NSMicrophoneUsageDescription` for microphone access

4. **Key Concepts**
   - Understand `SpeechAnalyzer` as the main coordinator
   - Learn `SpeechTranscriber` module setup and configuration
   - Master `AsyncStream` patterns for audio input
   - Implement proper audio format conversion with `AVAudioConverter`

## Critical Setup Sequence

Always follow this order to avoid runtime errors:

1. Create `SpeechTranscriber` with locale
2. Download language models via `AssetInventory`
3. **Allocate locale** (critical step after download)
4. Create `SpeechAnalyzer` with transcriber modules
5. Get best audio format
6. Create `AsyncStream<AnalyzerInput>` for input
7. Start analyzer with input sequence
8. Consume results from transcriber

## Examples

See the `examples/` directory for:
- Complete microphone transcription implementation
- Audio buffer conversion patterns
- Locale management and model downloads
- Error handling strategies
- SwiftUI integration examples

## Common Issues

### "Cannot use modules with unallocated locales"
**Solution**: Always call `transcriber.allocate(locale:)` after downloading models via `AssetInventory.assetInstallationRequest()`.

### Audio Timestamp Drift
**Solution**: Set `converter.primeMethod = .none` on your `AVAudioConverter` to prevent timestamp drift.

### Empty or Delayed Results
**Solution**: Ensure audio buffers are converted to the format returned by `SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith:)`.

## Resources

- [WWDC 2025 Session 277: What's new in Speech framework](https://developer.apple.com/videos/wwdc2025/)
- [Apple Speech Framework Documentation](https://developer.apple.com/documentation/speech)
- [SpeechAnalyzer Reference](https://developer.apple.com/documentation/speech/speechanalyzer)
- [SpeechTranscriber Reference](https://developer.apple.com/documentation/speech/speechtranscriber)
- [AssetInventory Documentation](https://developer.apple.com/documentation/speech/assetinventory)

## Migration Guide

### From WhisperKit
- Replace WhisperKit pipeline with SpeechAnalyzer
- Use native `AVAudioPCMBuffer` instead of Float arrays
- Leverage automatic model updates (no manual downloads)
- Switch from `Task` polling to `AsyncSequence` consumption

### From SFSpeechRecognizer
- Replace `SFSpeechRecognizer` with `SpeechAnalyzer`
- Update audio input from `SFSpeechAudioBufferRecognitionRequest` to `AsyncStream<AnalyzerInput>`
- Migrate result handling from delegate callbacks to async iteration
- Use `SpeechTranscriber.supportedLocales` instead of `SFSpeechRecognizer.supportedLocales()`
