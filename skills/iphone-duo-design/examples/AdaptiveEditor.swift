// Baseline example: Swift 5.9, Xcode 15, iOS 17+.
// Add AdaptiveEditor() to an app's WindowGroup.
// Each scene owns its own in-memory notebook. Persistence is intentionally absent.
import Foundation
import Observation
import SwiftUI

@available(iOS 17.0, *)
@MainActor
@Observable
final class DuoDraft: Identifiable {
    let id: UUID
    var title: String
    var text: String
    var isFavorite = false

    init(id: UUID = UUID(), title: String, text: String) {
        self.id = id
        self.title = title
        self.text = text
    }
}

@available(iOS 17.0, *)
@MainActor
@Observable
final class DuoNotebook {
    var drafts = [
        DuoDraft(title: "Trip notes", text: "Keep these edits while resizing."),
        DuoDraft(title: "Shopping", text: "Coffee, apples")
    ]
}

@available(iOS 17.0, *)
@MainActor
struct AdaptiveEditor: View {
    // The notebook outlives changes to the split view's presentation.
    @State private var notebook = DuoNotebook()
    @State private var selection: UUID?

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(notebook.drafts) { draft in
                    NavigationLink(draft.title, value: draft.id)
                }
            }
            .navigationTitle("Drafts")
        } detail: {
            if let draft = notebook.drafts.first(where: { $0.id == selection }) {
                DuoDraftEditor(draft: draft)
            } else {
                Text("Choose a draft")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

@available(iOS 17.0, *)
@MainActor
private struct DuoDraftEditor: View {
    @Bindable var draft: DuoDraft

    var body: some View {
        Form {
            Section("Title") {
                TextField("Title", text: $draft.title, axis: .vertical)
            }
            Section("Draft") {
                TextField("Draft", text: $draft.text, axis: .vertical)
                    .lineLimit(5...)
            }
        }
        .navigationTitle(draft.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    draft.isFavorite.toggle()
                } label: {
                    Label(
                        draft.isFavorite ? "Remove favorite" : "Add favorite",
                        systemImage: draft.isFavorite ? "star.fill" : "star"
                    )
                }
            }
        }
    }
}
