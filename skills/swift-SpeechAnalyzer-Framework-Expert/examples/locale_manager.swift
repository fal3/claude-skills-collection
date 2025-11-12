import Speech

/// Example: Locale management and model downloads
/// Demonstrates checking supported locales and downloading language models
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
