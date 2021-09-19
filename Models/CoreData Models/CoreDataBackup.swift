////
////  HabitItem+CoreDataProperties.swift
////  Persistent
////
////  Created by Bennett Quaritsch on 15.05.21.
////
////
//
//import Foundation
//import CoreData
//import SwiftUI
//
//public enum ResetIntervals {
//    case daily, weekly, monthly
//    
//    func getString() -> String {
//        switch self {
//        case .daily:
//            return "Day"
//        case .weekly:
//            return "Week"
//        case .monthly:
//            return "Month"
//        }
//    }
//}
//
//extension HabitItem {
//
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitItem> {
//        return NSFetchRequest<HabitItem>(entityName: "HabitItem")
//    }
//
//    @NSManaged public var amountToDo: Int16
//    @NSManaged public var habitDescription: String?
//    @NSManaged public var habitName: String
//    @NSManaged public var id: UUID
//    @NSManaged public var date: NSSet?
//    @NSManaged private var resetInterval: String
//    @NSManaged public var iconName: String?
//    @NSManaged public var iconColorIndex: Int16
//    @NSManaged public var habitDeleted: Bool
//    
//    public var resetIntervalEnum: ResetIntervals {
//        get {
//            switch resetInterval {
//            case "daily":
//                return .daily
//            case "weekly":
//                return .weekly
//            case "monthly":
//                return .monthly
//            default:
//                return .daily
//            }
//        }
//        set {
//            switch newValue {
//            case .daily:
//                resetInterval = "daily"
//            case .weekly:
//                resetInterval = "weekly"
//            case .monthly:
//                resetInterval = "monthly"
//            }
//        }
//    }
//
//    /// Array of each date linked to Habit, sorted
//    public var dateArray: [HabitCompletionDate] {
//        let set = date as? Set<HabitCompletionDate> ?? []
//        return set.sorted {
//            $0.date! < $1.date!
//        }
//    }
//    
//    /// Color of the habit´s icon
//    public var iconColor: Color {
//        let iconColors: [Color] = [Color.primary, Color.red, Color.orange, Color.yellow, Color.green, Color.pink, Color.purple]
//        return iconColors[Int(iconColorIndex)]
//    }
//    
//    func deleteHabit() {
//        self.habitDeleted = true
//    }
//    
//    func deleteHabitPermanently() {
//        PersistenceController.shared.container.viewContext.delete(self)
//    }
//    
//    /// Function for getting habit's count for its corresponding interval
//    func relevantCount(_ date: Date = Date()) -> Int {
//        let todayCount: [HabitCompletionDate]
//        switch self.resetIntervalEnum {
//        case .daily:
//            todayCount = self.dateArray.filter { Calendar.current.isDate($0.date!, equalTo: date, toGranularity: .day) }
//        case .weekly:
//            todayCount = self.dateArray.filter { Calendar.current.isDate($0.date!, equalTo: date, toGranularity: .weekOfYear) }
//        case .monthly:
//            todayCount = self.dateArray.filter { Calendar.current.isDate($0.date!, equalTo: date, toGranularity: .month) }
//        }
//        return todayCount.count
//    }
//    
//    ///Function for getting habit's progress
//    func progress(_ date: Date = Date()) -> CGFloat {
//        return CGFloat(self.relevantCount()) / CGFloat(self.amountToDo)
//    }
//}
//
//// MARK: Generated accessors for date
//extension HabitItem {
//
//    @objc(addDateObject:)
//    @NSManaged public func addToDate(_ value: HabitCompletionDate)
//
//    @objc(removeDateObject:)
//    @NSManaged public func removeFromDate(_ value: HabitCompletionDate)
//
//    @objc(addDate:)
//    @NSManaged public func addToDate(_ values: NSSet)
//
//    @objc(removeDate:)
//    @NSManaged public func removeFromDate(_ values: NSSet)
//
//}
//
//extension HabitItem : Identifiable {
//
//}
