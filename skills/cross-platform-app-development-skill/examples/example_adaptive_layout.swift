import SwiftUI

struct AdaptiveContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                // iPhone portrait or small screens
                VStack {
                    HeaderView()
                    ContentListView()
                    FooterView()
                }
            } else {
                // iPad or wide screens
                HStack {
                    SidebarView()
                    VStack {
                        HeaderView()
                        ContentListView()
                    }
                    DetailView()
                }
            }
        }
    }
}

struct HeaderView: View {
    var body: some View {
        Text("App Header")
            .font(.largeTitle)
            .padding()
    }
}

struct ContentListView: View {
    var body: some View {
        List(1...10, id: \.self) { item in
            Text("Item \(item)")
        }
    }
}

struct SidebarView: View {
    var body: some View {
        Text("Sidebar")
            .frame(width: 200)
            .background(Color.gray.opacity(0.2))
    }
}

struct DetailView: View {
    var body: some View {
        Text("Detail View")
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
    }
}

struct FooterView: View {
    var body: some View {
        Text("Footer")
            .padding()
    }
}