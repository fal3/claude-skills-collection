import SwiftUI

struct ToolbarExample: View {
    @State private var items = ["Welcome"]

    var body: some View {
        NavigationStack {
            List(items, id: \.self) { item in
                Text(item)
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add note", systemImage: "plus") {
                        items.append("Note \(items.count)")
                    }
                }
            }
        }
    }
}
