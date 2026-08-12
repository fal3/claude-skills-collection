import AVFoundation
import Foundation
import Speech

enum SpeechValidationFailure: LocalizedError, Sendable {
    case transcriberUnavailable
    case unsupportedLocale(String)
    case noCompatibleAudioFormat

    var errorDescription: String? {
        switch self {
        case .transcriberUnavailable:
            "This device cannot run SpeechTranscriber."
        case .unsupportedLocale(let identifier):
            "Speech transcription is unavailable for \(identifier)."
        case .noCompatibleAudioFormat:
            "No compatible analyzer audio format is installed."
        }
    }
}

@available(macOS 26.0, iOS 26.0, visionOS 26.0, tvOS 26.0, *)
@available(watchOS, unavailable)
func resolveSpeechLocale(_ requested: Locale) async throws -> Locale {
    guard SpeechTranscriber.isAvailable else {
        throw SpeechValidationFailure.transcriberUnavailable
    }
    guard let supported = await SpeechTranscriber.supportedLocale(
        equivalentTo: requested
    ) else {
        throw SpeechValidationFailure.unsupportedLocale(requested.identifier)
    }
    return supported
}

@available(macOS 26.0, iOS 26.0, visionOS 26.0, tvOS 26.0, *)
@available(watchOS, unavailable)
func requireAnalyzerFormat(for transcriber: SpeechTranscriber) async throws -> AVAudioFormat {
    guard let format = await SpeechAnalyzer.bestAvailableAudioFormat(
        compatibleWith: [transcriber]
    ) else {
        throw SpeechValidationFailure.noCompatibleAudioFormat
    }
    return format
}

@available(macOS 26.0, iOS 26.0, visionOS 26.0, tvOS 26.0, *)
@available(watchOS, unavailable)
actor SpeechResultAccumulator {
    private(set) var finalized = AttributedString()
    private(set) var volatile = AttributedString()

    func receive(_ result: SpeechTranscriber.Result) {
        if result.isFinal {
            finalized.append(result.text)
            volatile = AttributedString()
        } else {
            volatile = result.text
        }
    }

    var completeText: AttributedString {
        var text = finalized
        text.append(volatile)
        return text
    }

    var plainText: String {
        String(completeText.characters)
    }
}
