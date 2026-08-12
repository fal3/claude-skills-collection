import AVFoundation
import Foundation
import Speech

// The host app must provide NSSpeechRecognitionUsageDescription and
// NSMicrophoneUsageDescription. Compile this file with buffer_converter.swift.
@available(iOS 26.0, *)
@MainActor
final class LiveSpeechTranscriber {
    enum Failure: LocalizedError, Sendable {
        case alreadyRunning
        case speechRecognitionPermissionDenied
        case microphonePermissionDenied
        case transcriberUnavailable
        case unsupportedLocale(String)
        case noCompatibleAudioFormat
        case audioConversionFailed(String)
        case resultStreamFailed(String)

        var errorDescription: String? {
            switch self {
            case .alreadyRunning:
                "Live transcription is already starting or running."
            case .speechRecognitionPermissionDenied:
                "Speech recognition permission was denied."
            case .microphonePermissionDenied:
                "Microphone permission was denied."
            case .transcriberUnavailable:
                "SpeechTranscriber is unavailable on this device."
            case .unsupportedLocale(let identifier):
                "Speech transcription is unavailable for \(identifier)."
            case .noCompatibleAudioFormat:
                "No audio format is compatible with the transcriber."
            case .audioConversionFailed(let message):
                "Microphone audio conversion failed: \(message)"
            case .resultStreamFailed(let message):
                "Speech transcription failed: \(message)"
            }
        }
    }

    private(set) var finalizedTranscript = AttributedString()
    private(set) var volatileTranscript = AttributedString()
    private(set) var isRunning = false
    private(set) var lastFailure: Failure?

    var transcript: AttributedString {
        var text = finalizedTranscript
        text.append(volatileTranscript)
        return text
    }

    var onTranscriptChange: (@MainActor (AttributedString) -> Void)?
    var onFailure: (@MainActor (Failure) -> Void)?

    private var isStarting = false
    private var transcriber: SpeechTranscriber?
    private var analyzer: SpeechAnalyzer?
    private var audioEngine: AVAudioEngine?
    private var inputContinuation: AsyncStream<AnalyzerInput>.Continuation?
    private var resultTask: Task<Void, Never>?
    private var ownedReservedLocale: Locale?

    func start(requestedLocale: Locale = Locale(identifier: "en-US")) async throws {
        guard !isStarting, !isRunning else { throw Failure.alreadyRunning }
        isStarting = true
        defer { isStarting = false }

        try await requestPermissions()
        guard SpeechTranscriber.isAvailable else {
            throw Failure.transcriberUnavailable
        }
        guard let locale = await SpeechTranscriber.supportedLocale(
            equivalentTo: requestedLocale
        ) else {
            throw Failure.unsupportedLocale(requestedLocale.identifier)
        }

        let createdReservation = try await AssetInventory.reserve(locale: locale)
        ownedReservedLocale = createdReservation ? locale : nil

        do {
            let transcriber = SpeechTranscriber(
                locale: locale,
                preset: .progressiveTranscription
            )
            if let request = try await AssetInventory.assetInstallationRequest(
                supporting: [transcriber]
            ) {
                try await request.downloadAndInstall()
            }

            guard let analyzerFormat = await SpeechAnalyzer.bestAvailableAudioFormat(
                compatibleWith: [transcriber]
            ) else {
                throw Failure.noCompatibleAudioFormat
            }

            let analyzer = SpeechAnalyzer(modules: [transcriber])
            let (inputSequence, continuation) = AsyncStream.makeStream(
                of: AnalyzerInput.self
            )
            try await analyzer.start(inputSequence: inputSequence)

            self.transcriber = transcriber
            self.analyzer = analyzer
            self.inputContinuation = continuation
            finalizedTranscript = AttributedString()
            volatileTranscript = AttributedString()
            lastFailure = nil

            resultTask = Task { [weak self] in
                do {
                    for try await result in transcriber.results {
                        guard !Task.isCancelled else { return }
                        self?.receive(result)
                    }
                } catch is CancellationError {
                    // Explicit cancellation during stop.
                } catch {
                    self?.report(.resultStreamFailed(error.localizedDescription))
                }
            }

            let feeder = LiveAnalyzerAudioFeeder(
                converter: AnalyzerBufferConverter(outputFormat: analyzerFormat),
                continuation: continuation
            ) { [weak self] failure in
                Task { @MainActor [weak self] in
                    self?.report(failure)
                }
            }

            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement)
            try session.setActive(true)

            let engine = AVAudioEngine()
            let inputNode = engine.inputNode
            let inputFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(
                onBus: 0,
                bufferSize: 4_096,
                format: inputFormat
            ) { buffer, _ in
                feeder.receive(buffer)
            }

            audioEngine = engine
            engine.prepare()
            try engine.start()
            isRunning = true
        } catch {
            await stop()
            throw error
        }
    }

    func stop() async {
        if let audioEngine {
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.stop()
        }
        inputContinuation?.finish()

        if let analyzer {
            do {
                try await analyzer.finalizeAndFinishThroughEndOfInput()
            } catch {
                await analyzer.cancelAndFinishNow()
                resultTask?.cancel()
            }
        } else {
            resultTask?.cancel()
        }
        await resultTask?.value

        resultTask = nil
        inputContinuation = nil
        audioEngine = nil
        analyzer = nil
        transcriber = nil
        isRunning = false

        try? AVAudioSession.sharedInstance().setActive(
            false,
            options: .notifyOthersOnDeactivation
        )
        await releaseOwnedReservation()
    }

    private func requestPermissions() async throws {
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        guard speechStatus == .authorized else {
            throw Failure.speechRecognitionPermissionDenied
        }

        let microphoneGranted = await AVAudioApplication.requestRecordPermission()
        guard microphoneGranted else {
            throw Failure.microphonePermissionDenied
        }
    }

    private func receive(_ result: SpeechTranscriber.Result) {
        if result.isFinal {
            finalizedTranscript.append(result.text)
            volatileTranscript = AttributedString()
        } else {
            volatileTranscript = result.text
        }
        onTranscriptChange?(transcript)
    }

    private func report(_ failure: Failure) {
        lastFailure = failure
        onFailure?(failure)
    }

    private func releaseOwnedReservation() async {
        guard let locale = ownedReservedLocale else { return }
        ownedReservedLocale = nil
        await AssetInventory.release(reservedLocale: locale)
    }

    deinit {
        resultTask?.cancel()
        inputContinuation?.finish()
        audioEngine?.stop()

        if let locale = ownedReservedLocale {
            Task {
                await AssetInventory.release(reservedLocale: locale)
            }
        }
    }
}

@available(iOS 26.0, *)
private final class LiveAnalyzerAudioFeeder: @unchecked Sendable {
    private let converter: AnalyzerBufferConverter
    private let continuation: AsyncStream<AnalyzerInput>.Continuation
    private let reportFailure: @Sendable (LiveSpeechTranscriber.Failure) -> Void
    private let failureLock = NSLock()
    private var didReportFailure = false

    init(
        converter: AnalyzerBufferConverter,
        continuation: AsyncStream<AnalyzerInput>.Continuation,
        reportFailure: @escaping @Sendable (LiveSpeechTranscriber.Failure) -> Void
    ) {
        self.converter = converter
        self.continuation = continuation
        self.reportFailure = reportFailure
    }

    func receive(_ inputBuffer: AVAudioPCMBuffer) {
        do {
            let outputBuffer = try converter.convert(inputBuffer)
            guard outputBuffer.frameLength > 0 else { return }
            continuation.yield(AnalyzerInput(buffer: outputBuffer))
        } catch {
            failureLock.lock()
            let shouldReport = !didReportFailure
            didReportFailure = true
            failureLock.unlock()

            if shouldReport {
                reportFailure(.audioConversionFailed(error.localizedDescription))
            }
        }
    }
}
