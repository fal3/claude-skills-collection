---
name: SpeechAnalyzer Framework Expert
description: Expert guide for Apple's modern Speech framework (macOS 26+, iOS 26+) featuring SpeechAnalyzer and SpeechTranscriber for on-device speech-to-text transcription.
version: 1.0
activation: Activate for queries on Speech framework, SpeechAnalyzer, SpeechTranscriber, on-device speech recognition, audio transcription, or migrating from WhisperKit/SFSpeechRecognizer.
---

# SpeechAnalyzer Framework Expert

This skill provides comprehensive guidance on implementing Apple's modern Speech framework introduced for macOS 26+ and iOS 26+. The framework features `SpeechAnalyzer` and `SpeechTranscriber` for on-device speech-to-text transcription, offering 2.2x faster performance than Whisper Large V3 Turbo with out-of-process execution and automatic system updates.

## Best Practices

1. **Always allocate locale after model download**: Call `transcriber.allocate(locale:)` only after downloading assets via `AssetInventory.assetInstallationRequest()` to avoid "Cannot use modules with unallocated locales" errors.

2. **Use proper audio format conversion**: Convert audio buffers to the analyzer's required format using `AVAudioConverter` with `primeMethod = .none` to prevent timestamp drift.

3. **Follow the complete setup sequence**: Instantiate transcriber → download models → allocate locale → create analyzer → get best format → create AsyncStream → start analyzer → consume results. Skipping steps causes runtime errors.

4. **Leverage out-of-process execution**: The framework runs transcription in a separate process, eliminating memory limits in your app and providing automatic system updates without app redeployment.

5. **Handle both volatile and final results**: Process `result.isFinal` to distinguish between live transcription updates (volatile) and completed segments (final) for proper UI updates.

6. **Check locale support before use**: Use `SpeechTranscriber.supportedLocales` and `installedLocales` to verify language availability before creating transcriber instances.

7. **Implement proper AsyncStream lifecycle management**: Create input streams with `AsyncStream<AnalyzerInput>.makeStream()` and properly yield converted buffers to the continuation for reliable transcription.

8. **Use structured concurrency patterns**: Leverage async/await and actor isolation for thread-safe transcription state management and result processing.

9. **Monitor asset installation progress**: Track download progress for large language models to provide user feedback during initial setup.

10. **Handle transcription errors gracefully**: Catch and handle errors from `analyzer.start()` and result iteration to provide fallback behavior when transcription fails.

## Speech Framework Guidelines

- Use `SpeechAnalyzer` as the main coordinator, passing an array of modules like `[SpeechTranscriber]`
- Always get the best audio format with `SpeechAnalyzer.bestAvailableAudioFormat(compatibleWith:)` before processing
- Feed audio as `AnalyzerInput` objects containing converted `AVAudioPCMBuffer` instances
- Consume transcription results as `AsyncSequence` using `for try await result in transcriber.results`
- Support 10+ languages including English, Spanish, French, German, Italian, Japanese, Korean, Portuguese, Russian, Chinese
- Prefer on-device transcription for privacy-sensitive applications
- Use `reportingOptions: [.volatileResults]` for real-time live captioning
- Include `attributeOptions: [.audioTimeRange]` for precise word-level timing information
- Implement proper cleanup by canceling tasks and releasing analyzer references

## Examples

### Example 1: Basic SpeechAnalyzer Setup

**User Prompt:** "Show me how to set up SpeechAnalyzer with SpeechTranscriber for English transcription."

**Expected Output:**
```swift
import Speech

@MainActor
class TranscriptionManager {
    private var transcriber: SpeechTranscriber?
    private var analyzer: SpeechAnalyzer?
    private var inputContinuation: AsyncStream<AnalyzerInput>.Continuation?

    func setupTranscription() async throws {
        let locale = Locale(identifier: "en-US")

        // Step 1: Create transcriber
        let transcriber = SpeechTranscriber(
            locale: locale,
            transcriptionOptions: [],
            reportingOptions: [.volatileResults],
            attributeOptions: [.audioTimeRange]
        )

        // Step 2: Download model if needed
        if let request = try await AssetInventory.assetInstallationRequest(
            supporting: [transcriber]
        ) {
            try await request.downloadAndInstall()
        }

        // Step 3: CRITICAL - Allocate locale AFTER download
        try await transcriber.allocate(locale: locale)

        // Step 4: Create analyzer
        let analyzer = SpeechAnalyzer(modules: [transcriber])

        // Step 5: Get best format
        let format = await SpeechAnalyzer.bestAvailableAudioFormat(
            compatibleWith: [transcriber]
        )
        print("Best format: \(format)")

        // Step 6: Create AsyncStream for input
        let (inputSequence, inputBuilder) = AsyncStream<AnalyzerInput>.makeStream()
        self.inputContinuation = inputBuilder

        // Step 7: Start analyzer
        try await analyzer.start(inputSequence: inputSequence)

        // Store references
        self.transcriber = transcriber
        self.analyzer = analyzer

        // Step 8: Start consuming results
        Task {
            for try await result in transcriber.results {
                if result.isFinal {
                    print("Final: \(result.transcription)")
                } else {
                    print("Live: \(result.transcription)")
                }
            }
        }
    }
}
```

### Example 2: Audio Buffer Conversion

**User Prompt:** "How do I convert AVAudioPCMBuffer to the format required by SpeechAnalyzer?"

**Expected Output:**
```swift
import AVFoundation
import Speech

class BufferConverter {
    private var converter: AVAudioConverter?

    func convertBuffer(_ buffer: AVAudioPCMBuffer,
                       to format: AVAudioFormat) throws -> AVAudioPCMBuffer {
        // Create converter if needed or format changed
        if converter == nil || converter?.outputFormat != format {
            converter = AVAudioConverter(from: buffer.format, to: format)
            // CRITICAL: Prevents timestamp drift
            converter?.primeMethod = .none
        }

        guard let converter = converter else {
            throw ConversionError.converterCreationFailed
        }

        // Calculate output frame capacity
        let ratio = format.sampleRate / buffer.format.sampleRate
        let outputFrameCapacity = AVAudioFrameCount(ceil(Double(buffer.frameLength) * ratio))

        guard let outputBuffer = AVAudioPCMBuffer(
            pcmFormat: format,
            frameCapacity: outputFrameCapacity
        ) else {
            throw ConversionError.bufferAllocationFailed
        }

        var error: NSError?
        let status = converter.convert(to: outputBuffer, error: &error) { inPackets, outStatus in
            outStatus.pointee = .haveData
            return buffer
        }

        guard status != .error, error == nil else {
            throw ConversionError.conversionFailed(error)
        }

        return outputBuffer
    }

    enum ConversionError: Error {
        case converterCreationFailed
        case bufferAllocationFailed
        case conversionFailed(Error?)
    }
}
```

### Example 3: Complete Microphone Transcription

**User Prompt:** "Create a complete example that captures microphone audio and transcribes it in real-time."

**Expected Output:**
```swift
import AVFoundation
import Speech
import SwiftUI

@MainActor
@Observable
class LiveTranscriptionManager {
    var liveText: String = ""
    var finalText: String = ""
    var isRecording = false

    private var transcriber: SpeechTranscriber?
    private var analyzer: SpeechAnalyzer?
    private var audioEngine: AVAudioEngine?
    private var inputContinuation: AsyncStream<AnalyzerInput>.Continuation?
    private var bufferConverter = BufferConverter()
    private var analyzerFormat: AVAudioFormat?

    func startTranscription() async throws {
        let locale = Locale(identifier: "en-US")

        // Setup transcriber and analyzer
        let transcriber = SpeechTranscriber(
            locale: locale,
            transcriptionOptions: [],
            reportingOptions: [.volatileResults],
            attributeOptions: [.audioTimeRange]
        )

        // Download model if needed
        if let request = try await AssetInventory.assetInstallationRequest(
            supporting: [transcriber]
        ) {
            try await request.downloadAndInstall()
        }

        // Allocate locale
        try await transcriber.allocate(locale: locale)

        // Create analyzer
        let analyzer = SpeechAnalyzer(modules: [transcriber])

        // Get best format
        let format = await SpeechAnalyzer.bestAvailableAudioFormat(
            compatibleWith: [transcriber]
        )
        self.analyzerFormat = format

        // Create input stream
        let (inputSequence, inputBuilder) = AsyncStream<AnalyzerInput>.makeStream()
        self.inputContinuation = inputBuilder

        // Start analyzer
        try await analyzer.start(inputSequence: inputSequence)

        self.transcriber = transcriber
        self.analyzer = analyzer

        // Start consuming results
        Task {
            for try await result in transcriber.results {
                if result.isFinal {
                    self.finalText += result.transcription + " "
                    self.liveText = ""
                } else {
                    self.liveText = result.transcription
                }
            }
        }

        // Setup audio engine
        try setupAudioEngine()

        isRecording = true
    }

    private func setupAudioEngine() throws {
        let audioEngine = AVAudioEngine()
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] buffer, time in
            guard let self = self,
                  let analyzerFormat = self.analyzerFormat else { return }

            do {
                // Convert buffer to analyzer format
                let convertedBuffer = try self.bufferConverter.convertBuffer(
                    buffer,
                    to: analyzerFormat
                )

                // Feed to analyzer
                let input = AnalyzerInput(buffer: convertedBuffer)
                self.inputContinuation?.yield(input)
            } catch {
                print("Buffer conversion error: \(error)")
            }
        }

        audioEngine.prepare()
        try audioEngine.start()
        self.audioEngine = audioEngine
    }

    func stopTranscription() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        inputContinuation?.finish()

        audioEngine = nil
        analyzer = nil
        transcriber = nil
        isRecording = false
    }
}

// SwiftUI View
struct LiveTranscriptionView: View {
    @State private var manager = LiveTranscriptionManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("Live Transcription")
                .font(.title)

            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    if !manager.finalText.isEmpty {
                        Text(manager.finalText)
                            .foregroundColor(.primary)
                    }
                    if !manager.liveText.isEmpty {
                        Text(manager.liveText)
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .frame(maxHeight: 300)
            .background(Color(.systemGray6))
            .cornerRadius(10)

            Button(manager.isRecording ? "Stop" : "Start Recording") {
                Task {
                    if manager.isRecording {
                        manager.stopTranscription()
                    } else {
                        try? await manager.startTranscription()
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
```

### Example 4: Locale Management and Model Download

**User Prompt:** "How do I check which languages are supported and download models for a specific locale?"

**Expected Output:**
```swift
import Speech

@MainActor
class LocaleManager {
    func checkAndDownloadLocale(_ localeIdentifier: String) async throws -> Bool {
        let locale = Locale(identifier: localeIdentifier)

        // Check if locale is supported
        let supported = await SpeechTranscriber.supportedLocales
        guard supported.contains(locale) else {
            print("Locale \(localeIdentifier) is not supported")
            return false
        }

        // Check if already installed
        let installed = await SpeechTranscriber.installedLocales
        if installed.contains(locale) {
            print("Locale \(localeIdentifier) is already installed")
            return true
        }

        // Create temporary transcriber to check requirements
        let transcriber = SpeechTranscriber(
            locale: locale,
            transcriptionOptions: [],
            reportingOptions: [],
            attributeOptions: []
        )

        // Request installation
        if let request = try await AssetInventory.assetInstallationRequest(
            supporting: [transcriber]
        ) {
            print("Downloading models for \(localeIdentifier)...")

            // Monitor progress (optional)
            Task {
                for try await progress in request.progress {
                    print("Download progress: \(progress.fractionCompleted * 100)%")
                }
            }

            try await request.downloadAndInstall()
            print("Installation complete")
            return true
        }

        return true // Already available
    }

    func listAvailableLocales() async {
        let supported = await SpeechTranscriber.supportedLocales
        let installed = await SpeechTranscriber.installedLocales

        print("Supported locales:")
        for locale in supported {
            let status = installed.contains(locale) ? "✓ Installed" : "⬇ Available"
            print("  \(locale.identifier) - \(status)")
        }
    }
}
```

### Example 5: Error Handling and Recovery

**User Prompt:** "What are common errors when using SpeechAnalyzer and how do I handle them?"

**Expected Output:**
```swift
import Speech

@MainActor
class RobustTranscriptionManager {
    private var transcriber: SpeechTranscriber?
    private var analyzer: SpeechAnalyzer?

    enum TranscriptionError: Error {
        case localeNotAllocated
        case analyzerStartFailed
        case modelNotDownloaded
        case audioFormatMismatch
        case transcriptionFailed(Error)

        var userMessage: String {
            switch self {
            case .localeNotAllocated:
                return "Language not initialized. Please try again."
            case .analyzerStartFailed:
                return "Failed to start transcription service."
            case .modelNotDownloaded:
                return "Language model needs to be downloaded first."
            case .audioFormatMismatch:
                return "Audio format is incompatible with transcription."
            case .transcriptionFailed(let error):
                return "Transcription error: \(error.localizedDescription)"
            }
        }
    }

    func safeSetupTranscription(locale: Locale) async throws {
        do {
            // Step 1: Verify locale support
            let supported = await SpeechTranscriber.supportedLocales
            guard supported.contains(locale) else {
                throw TranscriptionError.modelNotDownloaded
            }

            // Step 2: Create transcriber
            let transcriber = SpeechTranscriber(
                locale: locale,
                transcriptionOptions: [],
                reportingOptions: [.volatileResults],
                attributeOptions: [.audioTimeRange]
            )

            // Step 3: Download model with error handling
            if let request = try await AssetInventory.assetInstallationRequest(
                supporting: [transcriber]
            ) {
                do {
                    try await request.downloadAndInstall()
                } catch {
                    throw TranscriptionError.modelNotDownloaded
                }
            }

            // Step 4: Allocate locale with retry
            do {
                try await transcriber.allocate(locale: locale)
            } catch {
                // Common error: "Cannot use modules with unallocated locales"
                throw TranscriptionError.localeNotAllocated
            }

            // Step 5: Create analyzer
            let analyzer = SpeechAnalyzer(modules: [transcriber])

            // Step 6: Get format and validate
            let format = await SpeechAnalyzer.bestAvailableAudioFormat(
                compatibleWith: [transcriber]
            )
            guard format.sampleRate > 0 else {
                throw TranscriptionError.audioFormatMismatch
            }

            // Step 7: Create input stream
            let (inputSequence, _) = AsyncStream<AnalyzerInput>.makeStream()

            // Step 8: Start analyzer with error handling
            do {
                try await analyzer.start(inputSequence: inputSequence)
            } catch {
                throw TranscriptionError.analyzerStartFailed
            }

            self.transcriber = transcriber
            self.analyzer = analyzer

            // Step 9: Consume results with error handling
            Task {
                do {
                    for try await result in transcriber.results {
                        processResult(result)
                    }
                } catch {
                    print("Result iteration error: \(error)")
                    throw TranscriptionError.transcriptionFailed(error)
                }
            }

        } catch let error as TranscriptionError {
            print("Transcription setup failed: \(error.userMessage)")
            throw error
        } catch {
            print("Unexpected error: \(error)")
            throw TranscriptionError.transcriptionFailed(error)
        }
    }

    private func processResult(_ result: SpeechTranscriptionResult) {
        // Process transcription result
        if result.isFinal {
            print("Final: \(result.transcription)")
        } else {
            print("Volatile: \(result.transcription)")
        }
    }
}
```
