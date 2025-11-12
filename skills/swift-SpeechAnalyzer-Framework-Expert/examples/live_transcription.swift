import AVFoundation
import Speech
import SwiftUI

/// Example: Complete live microphone transcription with SwiftUI
/// Demonstrates real-time audio capture, conversion, and transcription
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
