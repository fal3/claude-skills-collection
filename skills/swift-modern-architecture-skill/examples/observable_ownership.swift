import Observation
import SwiftUI

protocol ProfileSaving: Sendable {
    func save(displayName: String) async throws
}

@MainActor
@Observable
final class ProfileFeature {
    var displayName = ""
    private(set) var isSaving = false
    private(set) var errorMessage: String?

    private let saver: any ProfileSaving

    init(saver: any ProfileSaving) {
        self.saver = saver
    }

    func save() async {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            try await saver.save(displayName: displayName)
        } catch is CancellationError {
            return
        } catch {
            errorMessage = "The profile could not be saved."
        }
    }
}

@MainActor
struct ProfileScreen: View {
    @State private var feature: ProfileFeature

    init(saver: any ProfileSaving) {
        _feature = State(initialValue: ProfileFeature(saver: saver))
    }

    var body: some View {
        @Bindable var feature = feature

        Form {
            TextField("Display name", text: $feature.displayName)
            Button("Save") {
                Task { await feature.save() }
            }
            .disabled(feature.isSaving)

            if let errorMessage = feature.errorMessage {
                Text(errorMessage)
                    .foregroundStyle(.red)
            }
        }
    }
}
