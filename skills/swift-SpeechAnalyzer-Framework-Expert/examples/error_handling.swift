import Speech

/// Example: Comprehensive error handling for SpeechAnalyzer
/// Demonstrates common errors and recovery strategies
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
