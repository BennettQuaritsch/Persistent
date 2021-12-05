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
    @NSManaged public var habitValue: Int32

}

extension HabitCompletionDate : Identifiable {

}
