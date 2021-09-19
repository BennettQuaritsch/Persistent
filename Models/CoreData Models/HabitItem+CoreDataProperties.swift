//
//  HabitItem+CoreDataProperties.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 03.09.21.
//
//

import Foundation
import CoreData
import SwiftUI

public let iconColors: [Color] = [Color(UIColor.label),Color.pink, Color.red, Color.orange, Color.yellow, Color.green, Color(UIColor.cyan), Color(UIColor.systemTeal), Color(UIColor.systemBlue), Color(UIColor.systemIndigo), Color.purple, Color(UIColor.magenta), Color(UIColor.brown), Color(UIColor.gray)]

public enum ResetIntervals {
    case daily, weekly, monthly
    
    func getString() -> String {
        switch self {
        case .daily:
            return "Day"
        case .weekly:
            return "Week"
        case .monthly:
            return "Month"
        }
    }
}

extension HabitItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitItem> {
        return NSFetchRequest<HabitItem>(entityName: "HabitItem")
    }

    @NSManaged public var amountToDo: Int16
    @NSManaged public var habitDescription: String?
    @NSManaged public var habitName: String
    @NSManaged public var id: UUID
    @NSManaged public var date: NSSet?
    @NSManaged private var resetInterval: String
    @NSManaged public var iconName: String?
    @NSManaged public var iconColorIndex: Int16
    @NSManaged public var habitDeleted: Bool
    
    @NSManaged public var tags: NSSet?
    
    public var resetIntervalEnum: ResetIntervals {
        get {
            switch resetInterval {
            case "daily":
                return .daily
            case "weekly":
                return .weekly
            case "monthly":
                return .monthly
            default:
                return .daily
            }
        }
        set {
            switch newValue {
            case .daily:
                resetInterval = "daily"
            case .weekly:
                resetInterval = "weekly"
            case .monthly:
                resetInterval = "monthly"
            }
        }
    }

    /// Array of each date linked to Habit, sorted
    public var dateArray: [HabitCompletionDate] {
        let set = date as? Set<HabitCompletionDate> ?? []
        return set.sorted {
            $0.date! < $1.date!
        }
    }
    
    /// Color of the habit´s icon
    public var iconColor: Color {
        return iconColors[Int(iconColorIndex)]
    }
    
    func deleteHabit() {
        self.habitDeleted = true
    }
    
    func deleteHabitPermanently() {
        PersistenceController.shared.container.viewContext.delete(self)
    }
    
    /// Function for getting habit's count for its corresponding interval
    func relevantCount(_ date: Date = Date()) -> Int {
        let todayCount: [HabitCompletionDate]
        switch self.resetIntervalEnum {
        case .daily:
            todayCount = self.dateArray.filter { Calendar.current.isDate($0.date!, equalTo: date, toGranularity: .day) }
        case .weekly:
            todayCount = self.dateArray.filter { Calendar.current.isDate($0.date!, equalTo: date, toGranularity: .weekOfYear) }
        case .monthly:
            todayCount = self.dateArray.filter { Calendar.current.isDate($0.date!, equalTo: date, toGranularity: .month) }
        }
        return todayCount.count
    }
    
    ///Function for getting habit's progress
    func progress(_ date: Date = Date()) -> CGFloat {
        return CGFloat(self.relevantCount()) / CGFloat(self.amountToDo)
    }
    
    public var wrappedTags: [HabitTag] {
        var tagArray: [HabitTag] = []
        if let tags = self.tags {
            for tag in tags {
                if let tag = tag as? HabitTag {
                    tagArray.append(tag)
                }
            }
        }
        return tagArray
    }

}

// MARK: Generated accessors for date
extension HabitItem {

    @objc(addDateObject:)
    @NSManaged public func addToDate(_ value: HabitCompletionDate)

    @objc(removeDateObject:)
    @NSManaged public func removeFromDate(_ value: HabitCompletionDate)

    @objc(addDate:)
    @NSManaged public func addToDate(_ values: NSSet)

    @objc(removeDate:)
    @NSManaged public func removeFromDate(_ values: NSSet)

}

// MARK: Generated accessors for tags
extension HabitItem {

    @objc(addTagsObject:)
    @NSManaged public func addToTags(_ value: HabitTag)

    @objc(removeTagsObject:)
    @NSManaged public func removeFromTags(_ value: HabitTag)

    @objc(addTags:)
    @NSManaged public func addToTags(_ values: NSSet)

    @objc(removeTags:)
    @NSManaged public func removeFromTags(_ values: NSSet)

}

extension HabitItem : Identifiable {

}
