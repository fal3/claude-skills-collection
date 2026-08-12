import AVFoundation
import Foundation
import Speech

@available(macOS 26.0, iOS 26.0, visionOS 26.0, tvOS 26.0, *)
@available(watchOS, unavailable)
func transcribeAudioFile(
    at url: URL,
    using transcriber: SpeechTranscriber
) async throws -> AttributedString {
    let audioFile = try AVAudioFile(forReading: url)
    let analyzer = SpeechAnalyzer(modules: [transcriber])

    async let transcript = collectFinalTranscript(from: transcriber)

    do {
        try await analyzer.start(inputAudioFile: audioFile, finishAfterFile: true)
        return try await transcript
    } catch {
        await analyzer.cancelAndFinishNow()
        throw error
    }
}

@available(macOS 26.0, iOS 26.0, visionOS 26.0, tvOS 26.0, *)
@available(watchOS, unavailable)
private func collectFinalTranscript(
    from transcriber: SpeechTranscriber
) async throws -> AttributedString {
    var transcript = AttributedString()
    for try await result in transcriber.results where result.isFinal {
        transcript.append(result.text)
    }
    return transcript
}

// Call from the scope in basic_setup.swift:
//
// let text = try await withPreparedSpeechTranscriber(
//     requestedLocale: Locale(identifier: "en-US")
// ) { transcriber, _ in
//     try await transcribeAudioFile(at: audioURL, using: transcriber)
// }
