//
//  HabitCompletionDate+CoreDataProperties.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 15.05.21.
//
//

import Foundation
import CoreData


extension HabitCompletionDate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitCompletionDate> {
        return NSFetchRequest<HabitCompletionDate>(entityName: "HabitCompletionDate")
    }

    @NSManaged public var date: Date?
    @NSManaged public var item: HabitItem?
    @NSManaged public var habitValue: Int64
    
    public var wrappedHabitValue: Int {
        get {
            Int(habitValue)
        }
        set {
            habitValue = Int64(newValue)
        }
    }

}

extension HabitCompletionDate : Identifiable {

}
