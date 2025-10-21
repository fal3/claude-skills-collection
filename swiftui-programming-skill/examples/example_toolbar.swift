import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            Text("Hello, World!")
                .navigationTitle("My App")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            // Action for leading button
                        }) {
                            Image(systemName: "line.horizontal.3")
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            // Action for trailing button
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
        }
    }
}