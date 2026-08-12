import Foundation
import Speech

@available(macOS 26.0, iOS 26.0, visionOS 26.0, tvOS 26.0, *)
@available(watchOS, unavailable)
actor SpeechLocaleAssetManager {
    enum Failure: LocalizedError, Sendable {
        case transcriberUnavailable
        case unsupportedLocale(String)

        var errorDescription: String? {
            switch self {
            case .transcriberUnavailable:
                "SpeechTranscriber is unavailable on this device."
            case .unsupportedLocale(let identifier):
                "No supported locale is equivalent to \(identifier)."
            }
        }
    }

    private var ownedReservations: Set<Locale> = []

    func install(
        requestedLocale: Locale,
        onProgressAvailable: (@Sendable (Progress) -> Void)? = nil
    ) async throws -> Locale {
        guard SpeechTranscriber.isAvailable else {
            throw Failure.transcriberUnavailable
        }
        guard let locale = await SpeechTranscriber.supportedLocale(
            equivalentTo: requestedLocale
        ) else {
            throw Failure.unsupportedLocale(requestedLocale.identifier)
        }

        let createdReservation = try await AssetInventory.reserve(locale: locale)

        do {
            let transcriber = SpeechTranscriber(locale: locale, preset: .transcription)
            if let request = try await AssetInventory.assetInstallationRequest(
                supporting: [transcriber]
            ) {
                // Foundation Progress is observable/inspectable, but is not an AsyncSequence.
                onProgressAvailable?(request.progress)
                try await request.downloadAndInstall()
            }

            if createdReservation {
                ownedReservations.insert(locale)
            }
            return locale
        } catch {
            if createdReservation {
                await AssetInventory.release(reservedLocale: locale)
            }
            throw error
        }
    }

    func release(_ locale: Locale) async {
        guard ownedReservations.remove(locale) != nil else { return }
        await AssetInventory.release(reservedLocale: locale)
    }

    func releaseAll() async {
        let locales = ownedReservations
        ownedReservations.removeAll()
        for locale in locales {
            await AssetInventory.release(reservedLocale: locale)
        }
    }
}
