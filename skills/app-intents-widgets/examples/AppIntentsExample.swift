import AppIntents
import Foundation

enum ProjectPriority: String, AppEnum {
    case normal
    case urgent

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Project Priority"
    }

    static var caseDisplayRepresentations: [ProjectPriority: DisplayRepresentation] {
        [
            .normal: "Normal",
            .urgent: "Urgent"
        ]
    }
}

struct ProjectSnapshot: Sendable, Equatable {
    let id: UUID
    // Use only a product-approved alias that is safe for system surfaces.
    let safeDisplayName: String
    let isComplete: Bool
    let priority: ProjectPriority
}

actor ProjectStore {
    private var projects: [UUID: ProjectSnapshot]

    init(projects: [ProjectSnapshot]) {
        self.projects = Dictionary(uniqueKeysWithValues: projects.map { ($0.id, $0) })
    }

    func projects(for identifiers: [UUID]) -> [ProjectSnapshot] {
        identifiers.compactMap { projects[$0] }
    }

    func suggestions(limit: Int) -> [ProjectSnapshot] {
        Array(projects.values.filter { !$0.isComplete }.prefix(limit))
    }

    func search(_ text: String, limit: Int) -> [ProjectSnapshot] {
        Array(
            projects.values
                .filter { $0.safeDisplayName.localizedCaseInsensitiveContains(text) }
                .prefix(limit)
        )
    }

    func complete(id: UUID, priority: ProjectPriority?) throws -> ProjectSnapshot {
        guard let existing = projects[id] else {
            throw ProjectError.notFound
        }
        let updated = ProjectSnapshot(
            id: id,
            safeDisplayName: existing.safeDisplayName,
            isComplete: true,
            priority: priority ?? existing.priority
        )
        projects[id] = updated
        return updated
    }
}

enum ProjectError: Error, Sendable {
    case notFound
}

struct ProjectEntity: AppEntity {
    let id: UUID
    let safeDisplayName: String
    let isComplete: Bool
    let priority: ProjectPriority

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Project"
    }

    static let defaultQuery = ProjectQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(safeDisplayName)",
            subtitle: "\(isComplete ? "Complete" : "Active") · \(priority == .urgent ? "Urgent" : "Normal")"
        )
    }

    init(snapshot: ProjectSnapshot) {
        id = snapshot.id
        safeDisplayName = snapshot.safeDisplayName
        isComplete = snapshot.isComplete
        priority = snapshot.priority
    }
}

struct ProjectQuery: EntityQuery, EntityStringQuery {
    @Dependency private var store: ProjectStore

    init() {}

    func entities(for identifiers: [UUID]) async throws -> [ProjectEntity] {
        await store.projects(for: identifiers).map(ProjectEntity.init)
    }

    func suggestedEntities() async throws -> [ProjectEntity] {
        await store.suggestions(limit: 10).map(ProjectEntity.init)
    }

    func entities(matching string: String) async throws -> [ProjectEntity] {
        await store.search(string, limit: 20).map(ProjectEntity.init)
    }
}

struct CompleteProjectIntent: AppIntent {
    static let title: LocalizedStringResource = "Complete Project"
    static let description = IntentDescription("Marks a project as complete.")
    static let authenticationPolicy: IntentAuthenticationPolicy = .requiresAuthentication

    @Parameter(title: "Project")
    var project: ProjectEntity

    @Parameter(title: "Priority")
    var priority: ProjectPriority?

    @Dependency private var store: ProjectStore

    static var parameterSummary: some ParameterSummary {
        Summary("Complete \(\.$project)") {
            \.$priority
        }
    }

    func perform() async throws -> some IntentResult & ReturnsValue<ProjectEntity> & ProvidesDialog {
        // Use a custom confirmation dialog on iOS 18+ when the product needs
        // more context. This baseline call remains available on iOS 16.
        try await requestConfirmation()
        let updated = try await store.complete(id: project.id, priority: priority)
        return .result(
            value: ProjectEntity(snapshot: updated),
            dialog: "Completed \(updated.safeDisplayName)."
        )
    }
}

struct ProjectShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CompleteProjectIntent(),
            phrases: [
                "Complete a project in \(.applicationName)"
            ],
            shortTitle: "Complete Project",
            systemImageName: "checkmark.circle"
        )
    }
}

func registerProjectIntentDependencies(store: ProjectStore) {
    AppDependencyManager.shared.add(dependency: store)
}
