import SwiftUI

struct AdaptiveLayoutExample: View {
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(alignment: .top, spacing: 24) {
                SummaryPanel()
                DetailPanel()
            }

            VStack(alignment: .leading, spacing: 16) {
                SummaryPanel()
                DetailPanel()
            }
        }
        .padding()
    }
}

private struct SummaryPanel: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Summary")
                .font(.headline)
            Text("Shared content chooses a layout from the available space.")
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct DetailPanel: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Details")
                .font(.headline)
            Text("Platform-specific behavior belongs behind a capability boundary.")
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
