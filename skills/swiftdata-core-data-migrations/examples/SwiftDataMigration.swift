import Foundation
import SwiftData

enum RemindersSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        Schema.Version(1, 0, 0)
    }

    static var models: [any PersistentModel.Type] {
        [Reminder.self]
    }

    @Model
    final class Reminder {
        var title: String
        var createdAt: Date

        init(title: String, createdAt: Date) {
            self.title = title
            self.createdAt = createdAt
        }
    }
}

enum RemindersSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version {
        Schema.Version(2, 0, 0)
    }

    static var models: [any PersistentModel.Type] {
        [Reminder.self]
    }

    @Model
    final class Reminder {
        @Attribute(originalName: "title")
        var name: String
        var createdAt: Date
        var notes: String?

        init(name: String, createdAt: Date, notes: String? = nil) {
            self.name = name
            self.createdAt = createdAt
            self.notes = notes
        }
    }
}

enum RemindersMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [RemindersSchemaV1.self, RemindersSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [
            .lightweight(
                fromVersion: RemindersSchemaV1.self,
                toVersion: RemindersSchemaV2.self
            )
        ]
    }
}

func makeRemindersContainer(storeURL: URL) throws -> ModelContainer {
    let schema = Schema(versionedSchema: RemindersSchemaV2.self)
    let configuration = ModelConfiguration(url: storeURL)
    return try ModelContainer(
        for: schema,
        migrationPlan: RemindersMigrationPlan.self,
        configurations: configuration
    )
}
