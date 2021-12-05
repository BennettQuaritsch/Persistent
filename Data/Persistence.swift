//
//  Persistence.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 14.05.21.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController()
//        let viewContext = result.container.viewContext
//        for i in 0..<3 {
//            let habit = HabitItem(context: viewContext)
//            habit.id = UUID()
//            habit.habitName = "PreviewTest"
//            habit.iconName = iconChoices.randomElement()!
//            habit.resetIntervalEnum = .daily
//            habit.amountToDo = 4
//            habit.iconColorIndex = Int16(iconColors.firstIndex(of: iconColors.randomElement()!)!)
//            
//            for _ in 1...Int.random(in: 1...6) {
//                let date = HabitCompletionDate(context: viewContext)
//                date.date = Date()
//                date.item = habit
//            }
//        }
//        do {
//            try viewContext.save()
//        } catch {
//            // Replace this implementation with code to handle the error appropriately.
//            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init() {
        container = NSPersistentCloudKitContainer(name: "Persistent")
        
        let storeURL = URL.storeURL(for: "group.persistentData", databaseName: "PersistentDatabase")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.shouldInferMappingModelAutomatically = true
        storeDescription.shouldMigrateStoreAutomatically = true
        
        let syncEnabled: Bool = UserDefaults.standard.bool(forKey: "syncEnabled")
        
        if syncEnabled {
            storeDescription.cloudKitContainerOptions  = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.PersistentCloudKit")
        }
        
        container.persistentStoreDescriptions = [storeDescription]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
    }
}

public extension URL {

    /// Returns a URL for the given app group and database pointing to the sqlite database.
    static func storeURL(for appGroup: String, databaseName: String) -> URL {
        guard let fileContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            fatalError("Shared file container could not be created.")
        }

        return fileContainer.appendingPathComponent("\(databaseName).sqlite")
    }
}
