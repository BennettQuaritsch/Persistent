//
//  NotificationItem+CoreDataProperties.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 28.09.21.
//
//

import Foundation
import CoreData


extension NotificationItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificationItem> {
        return NSFetchRequest<NotificationItem>(entityName: "NotificationItem")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var habit: HabitItem?

}

extension NotificationItem : Identifiable {

}
