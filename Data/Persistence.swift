//
//  Persistence.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 14.05.21.
//

import CoreData
import SwiftUI

final class PersistenceController {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController()
        let viewContext = result.container.viewContext
        for i in 0..<3 {
            let habit = HabitItem(context: viewContext)
            habit.id = UUID()
            habit.habitName = "PreviewTest"
        
            habit.resetIntervalEnum = .daily
        
            habit.amountToDo = 4
            habit.wrappedStandardAddValue = 1
        
            habit.iconName = IconSection.sections.randomElement()!.iconArray.randomElement()!
            habit.wrappedIconColorName = Color.iconColors.randomElement()!.name
        
            habit.habitArchived = false
            habit.breakHabit = false
        
            habit.valueTypeEnum = .number
            
            let date = HabitCompletionDate(context: viewContext)
            date.date = Date()
            date.item = habit
            date.habitValue = 5
            
            let quickAdd = HabitQuickAddAction(context: viewContext)
            quickAdd.id = UUID()
            quickAdd.wrappedName = "Test"
            quickAdd.value = 3
            quickAdd.habit = habit
            
            let habitTag = HabitTag(context: viewContext)
            habitTag.wrappedName = "\(i)"
            habitTag.id = UUID()
            
        }
        
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

    var container: NSPersistentCloudKitContainer

    init() {
//        self.container = initializePersistentContainer()
        container = NSPersistentCloudKitContainer(name: "Persistent")

        let storeURL = URL.storeURL(for: "group.persistentData", databaseName: "PersistentDatabase")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.shouldInferMappingModelAutomatically = true
        storeDescription.shouldMigrateStoreAutomatically = true

//        let syncDisabled: Bool = UserDefaults.standard.bool(forKey: "syncDisabled")
//
//        if !syncDisabled {
//            storeDescription.cloudKitContainerOptions  = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.PersistentCloudKit")
//        }
        storeDescription.cloudKitContainerOptions  = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.PersistentCloudKit")
        
        storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        storeDescription.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
        storeDescription.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)

        container.persistentStoreDescriptions = [storeDescription]



        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

//        try? container.viewContext.setQueryGenerationFrom(.current)
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
