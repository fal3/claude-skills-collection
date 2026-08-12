import AVFoundation
import Foundation
import Speech

enum SpeechPreparationFailure: LocalizedError, Sendable {
    case transcriberUnavailable
    case unsupportedLocale(String)
    case noCompatibleAudioFormat

    var errorDescription: String? {
        switch self {
        case .transcriberUnavailable:
            "SpeechTranscriber is unavailable on this device."
        case .unsupportedLocale(let identifier):
            "No supported speech locale is equivalent to \(identifier)."
        case .noCompatibleAudioFormat:
            "No installed audio format is compatible with the transcriber."
        }
    }
}

@available(macOS 26.0, iOS 26.0, visionOS 26.0, tvOS 26.0, *)
@available(watchOS, unavailable)
func withPreparedSpeechTranscriber<Result: Sendable>(
    requestedLocale: Locale,
    operation: @Sendable (SpeechTranscriber, AVAudioFormat) async throws -> Result
) async throws -> Result {
    guard SpeechTranscriber.isAvailable else {
        throw SpeechPreparationFailure.transcriberUnavailable
    }
    guard let locale = await SpeechTranscriber.supportedLocale(
        equivalentTo: requestedLocale
    ) else {
        throw SpeechPreparationFailure.unsupportedLocale(requestedLocale.identifier)
    }

    let createdReservation = try await AssetInventory.reserve(locale: locale)

    do {
        let transcriber = SpeechTranscriber(locale: locale, preset: .progressiveTranscription)

        if let request = try await AssetInventory.assetInstallationRequest(
            supporting: [transcriber]
        ) {
            try await request.downloadAndInstall()
        }

        guard let format = await SpeechAnalyzer.bestAvailableAudioFormat(
            compatibleWith: [transcriber]
        ) else {
            throw SpeechPreparationFailure.noCompatibleAudioFormat
        }

        let value = try await operation(transcriber, format)
        if createdReservation {
            await AssetInventory.release(reservedLocale: locale)
        }
        return value
    } catch {
        if createdReservation {
            await AssetInventory.release(reservedLocale: locale)
        }
        throw error
    }
}
