import SwiftUI

struct VoiceOverExample: View {
    @State private var isFavorite = false

    var body: some View {
        Button {
            isFavorite.toggle()
        } label: {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .font(.largeTitle)
        }
        .accessibilityLabel(isFavorite ? "Remove from Favorites" : "Add to Favorites")
        .accessibilityValue(isFavorite ? "Favorite" : "Not favorite")
    }
}
