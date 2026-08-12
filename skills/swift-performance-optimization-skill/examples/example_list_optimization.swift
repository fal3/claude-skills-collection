import SwiftUI

struct PerformanceItem: Identifiable, Sendable {
    let id: Int
    let title: String
}

struct MeasuredListExample: View {
    let items: [PerformanceItem]

    var body: some View {
        List(items) { item in
            HStack {
                Text(item.title)
                Spacer()
                Image(systemName: "star")
                    .foregroundStyle(.yellow)
                    .accessibilityHidden(true)
            }
        }
        .listStyle(.plain)
    }
}

// List already realizes rows lazily. Choose this variant when custom scrolling
// behavior or styling requires it, then profile both versions for the real data.
struct CustomScrollingExample: View {
    let items: [PerformanceItem]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(items) { item in
                    Text(item.title)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                }
            }
            .padding(.horizontal)
        }
    }
}
