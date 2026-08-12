import SwiftUI

struct ToggleExample: View {
    @State private var usesCalmTheme = false

    var body: some View {
        ZStack {
            (usesCalmTheme ? Color.blue : Color.gray)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text(usesCalmTheme ? "Calm theme" : "Neutral theme")
                    .font(.largeTitle)
                    .foregroundStyle(.white)

                Toggle("Use calm theme", isOn: $usesCalmTheme)
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
    }
}
