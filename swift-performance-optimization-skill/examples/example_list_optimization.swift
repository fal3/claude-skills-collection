import SwiftUI

struct OptimizedListView: View {
    let items = Array(1...10000) // Large dataset
    
    var body: some View {
        List(items, id: \.self) { item in
            OptimizedRowView(item: item)
        }
        .listStyle(.plain)
    }
}

struct OptimizedRowView: View {
    let item: Int
    
    var body: some View {
        HStack {
            Text("Item \(item)")
            Spacer()
            Image(systemName: "star")
                .foregroundColor(.yellow)
        }
        .padding(.vertical, 8)
        // Avoid complex computations in body
        // Use @StateObject for view models if needed
    }
}

// For even better performance with large datasets:
struct LazyOptimizedListView: View {
    let items = Array(1...10000)
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(items, id: \.self) { item in
                    OptimizedRowView(item: item)
                }
            }
        }
    }
}