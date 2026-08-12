import SwiftUI

struct PlatformSpecificExample: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Shared account status")

            #if targetEnvironment(macCatalyst)
            Label("Running with Mac Catalyst", systemImage: "macwindow")
            #elseif os(iOS)
            Label("Touch and keyboard actions", systemImage: "iphone")
            #elseif os(macOS)
            Label("Commands and multiple windows", systemImage: "macwindow")
            #elseif os(watchOS)
            Label("Glanceable watch action", systemImage: "applewatch")
            #elseif os(tvOS)
            Label("Focus-driven TV action", systemImage: "appletv")
            #elseif os(visionOS)
            Label("Windowed spatial action", systemImage: "visionpro")
            #else
            Text("Unsupported platform")
            #endif
        }
        .padding()
    }
}
