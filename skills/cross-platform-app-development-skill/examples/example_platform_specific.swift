import SwiftUI

struct CrossPlatformView: View {
    var body: some View {
        VStack {
            Text("Shared Content")
            
            #if os(iOS)
            iOSOnlyView()
            #elseif os(macOS)
            MacOnlyView()
            #elseif os(watchOS)
            WatchOnlyView()
            #elseif os(tvOS)
            TVOnlyView()
            #endif
        }
    }
}

#if os(iOS)
struct iOSOnlyView: View {
    var body: some View {
        Button("iOS Specific Button") {
            // iOS specific action
        }
        .buttonStyle(.borderedProminent)
    }
}
#endif

#if os(macOS)
struct MacOnlyView: View {
    var body: some View {
        Button("macOS Specific Button") {
            // macOS specific action
        }
        .buttonStyle(.bordered)
    }
}
#endif

#if os(watchOS)
struct WatchOnlyView: View {
    var body: some View {
        Text("WatchOS Interface")
            .font(.caption)
    }
}
#endif

#if os(tvOS)
struct TVOnlyView: View {
    var body: some View {
        Button("TV Button") {
            // TV specific action
        }
        .font(.title)
        .padding()
    }
}
#endif