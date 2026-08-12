import Foundation
import SwiftUI
import WidgetKit

// The rendered widget types require iOS 17 because containerBackground(for:)
// is used. Keep an iOS 14-16 widget on its earlier background path instead.

struct ProjectWidgetSnapshot: Codable, Sendable, Equatable {
    let activeCount: Int
    let updatedAt: Date
}

struct SharedProjectWidgetStore: Sendable {
    let suiteName: String

    func load() -> ProjectWidgetSnapshot? {
        guard
            let defaults = UserDefaults(suiteName: suiteName),
            let data = defaults.data(forKey: "project-widget-snapshot")
        else {
            return nil
        }
        return try? JSONDecoder().decode(ProjectWidgetSnapshot.self, from: data)
    }
}

struct ProjectWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: ProjectWidgetSnapshot?
}

struct ProjectTimelineProvider: TimelineProvider {
    let store = SharedProjectWidgetStore(suiteName: "group.com.example.projects")

    func placeholder(in context: Context) -> ProjectWidgetEntry {
        ProjectWidgetEntry(
            date: Date(),
            snapshot: ProjectWidgetSnapshot(activeCount: 3, updatedAt: Date())
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (ProjectWidgetEntry) -> Void
    ) {
        completion(ProjectWidgetEntry(date: Date(), snapshot: store.load()))
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<ProjectWidgetEntry>) -> Void
    ) {
        let now = Date()
        let entry = ProjectWidgetEntry(date: now, snapshot: store.load())
        let nextRefresh = Calendar.current.date(
            byAdding: .minute,
            value: 30,
            to: now
        ) ?? now.addingTimeInterval(1_800)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

@available(iOS 17.0, *)
struct ProjectWidgetView: View {
    let entry: ProjectWidgetEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Active Projects")
                .font(.headline)
            Text(entry.snapshot.map { String($0.activeCount) } ?? "—")
                .font(.largeTitle)
            Spacer()
            if let projectsURL = URL(string: "projects://list") {
                Link(destination: projectsURL) {
                    Label("Open", systemImage: "arrow.up.forward.app")
                }
            }
        }
        .containerBackground(for: .widget) {
            Color.blue.opacity(0.15)
        }
    }
}

@available(iOS 17.0, *)
struct ProjectWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "ProjectWidget",
            provider: ProjectTimelineProvider()
        ) { entry in
            ProjectWidgetView(entry: entry)
        }
        .configurationDisplayName("Projects")
        .description("Shows the current number of active projects.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
