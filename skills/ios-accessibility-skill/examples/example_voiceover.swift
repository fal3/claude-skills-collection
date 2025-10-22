import SwiftUI

struct AccessibleButtonView: View {
    var body: some View {
        VStack {
            Button(action: {
                // Action
            }) {
                Image(systemName: "star.fill")
                    .font(.largeTitle)
            }
            .accessibilityLabel("Favorite this item")
            .accessibilityHint("Double tap to add to favorites")
            
            Button("Submit", action: {
                // Submit action
            })
            .accessibilityHint("This will send your information")
        }
    }
}