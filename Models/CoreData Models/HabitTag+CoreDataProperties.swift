//
//  HabitTag+CoreDataProperties.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 03.09.21.
//
//

import Foundation
import CoreData


extension HabitTag {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitTag> {
        return NSFetchRequest<HabitTag>(entityName: "HabitTag")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var containingHabits: NSSet?
    
    public var wrappedName: String {
        get {
            name ?? "Untitled Tag"
        }
        set {
            name = newValue
        }
    }
    
    public var wrappedId: UUID {
        get {
            id ?? UUID()
        }
        set {
            id = newValue
        }
    }

    func deleteTag() {
        PersistenceController.shared.container.viewContext.delete(self)
    }
}

extension HabitTag : Identifiable {

}
