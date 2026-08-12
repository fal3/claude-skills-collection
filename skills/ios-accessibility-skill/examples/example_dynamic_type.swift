import SwiftUI

struct DynamicTypeExample: View {
    @ScaledMetric(relativeTo: .body) private var iconSize = 24.0

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Image(systemName: "textformat.size")
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .accessibilityHidden(true)

            Text("This message wraps at every Dynamic Type size, including accessibility sizes.")
                .font(.body)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
    }
}
