import SwiftUI

struct DynamicTextView: View {
    var body: some View {
        VStack {
            Text("This text scales with Dynamic Type")
                .font(.body)
            
            Text("Headline that adapts")
                .font(.headline)
            
            Text("Custom font that scales")
                .font(.system(size: 17, weight: .regular, design: .default))
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .padding()
    }
}