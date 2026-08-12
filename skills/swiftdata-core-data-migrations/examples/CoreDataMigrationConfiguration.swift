import CoreData
import Foundation

func automaticStoreDescription(at storeURL: URL) -> NSPersistentStoreDescription {
    let description = NSPersistentStoreDescription(url: storeURL)
    description.shouldMigrateStoreAutomatically = true
    description.shouldInferMappingModelAutomatically = true
    return description
}

struct ExplicitCoreDataMigration {
    let sourceModel: NSManagedObjectModel
    let destinationModel: NSManagedObjectModel
    let mappingModel: NSMappingModel

    func migrate(from sourceURL: URL, to destinationURL: URL) throws {
        let manager = NSMigrationManager(
            sourceModel: sourceModel,
            destinationModel: destinationModel
        )

        try manager.migrateStore(
            from: sourceURL,
            sourceType: NSSQLiteStoreType,
            options: nil,
            with: mappingModel,
            toDestinationURL: destinationURL,
            destinationType: NSSQLiteStoreType,
            destinationOptions: nil
        )
    }
}
