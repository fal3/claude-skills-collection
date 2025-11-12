import Speech

/// Example: Basic SpeechAnalyzer setup with SpeechTranscriber
/// Demonstrates the critical 8-step setup sequence
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
