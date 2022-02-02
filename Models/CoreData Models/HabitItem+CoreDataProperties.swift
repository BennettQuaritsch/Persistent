//
//  HabitItem+CoreDataProperties.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 29.09.21.
//
//

//import Foundation
//import CoreData
//
//
//extension HabitItem {
//
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitItem> {
//        return NSFetchRequest<HabitItem>(entityName: "HabitItem")
//    }
//
//    @NSManaged public var amountToDo: Int16
//    @NSManaged public var habitDeleted: Bool
//    @NSManaged public var habitDescription: String?
//    @NSManaged public var habitName: String?
//    @NSManaged public var iconColorIndex: Int16
//    @NSManaged public var iconName: String?
//    @NSManaged public var id: UUID?
//    @NSManaged public var resetInterval: String?
//    @NSManaged public var iconColorName: String?
//    @NSManaged public var date: NSSet?
//    @NSManaged public var tags: NSSet?
//    @NSManaged public var notificationDates: NSSet?
//
//}

import Foundation
import CoreData
import SwiftUI

public let iconColors: [Color] = [Color("primary"), Color("pink"), Color("red"), Color("orange"), Color("yellow"), Color("green"), Color("cyan"), Color("teal"), Color("blue"), Color("indigo"), Color("purple"), Color("magenta"), Color("brown"), Color("gray")]



struct IconSection: Hashable {
    let name: String
    let iconArray: [String]
}

let iconSections: [IconSection] = [
    .init(name: "Sport", iconArray: ["american-football", "barbell", "baseball", "tennisball", "basketball", "bowling-ball", "fitness", "football", "bicycle", ]),
    .init(name: "Food", iconArray: ["restaurant", "nutrition", "pizza", "beer", "ice-cream", "cafe", "fast-food", "fish", "pint", "wine"]),
    .init(name: "People and animals", iconArray: ["man", "woman", "walk", "body", "person", "people", "happy", "sad", "eye", "footsteps", "hand-left", "ear", "paw", "thumbs-up", "thumbs-down", ]),
    .init(name: "Tech", iconArray: ["desktop", "laptop", "tv", "watch", "headset", "mic", "game-controller", "hardware-chip", "git-branch", "qr-code", "camera", "videocam", "aperture", "calculator", "code-slash", "terminal", "save", "disc", "server", ]),
    .init(name: "Objects", iconArray: ["car-sport", "car", "bus", "subway", "airplane", "boat", "rocket", "archive", "bag", "balloon", "bandage", "basket", "bed", "book", "reader", "brush", "pencil", "build", "hammer", "bug", "bulb", "business", "calendar", "call", "cart", "wallet", "cash", "card", "briefcase", "cut", "dice", "earth", "extension-puzzle", "file-tray", "film", "flag", "flame", "flash", "flask", "leaf", "flower", "rose", "gift", "glasses", "golf", "hourglass", "id-card", "image", "library", "journal", "newspaper", "key", "lock-closed", "magnet", "medkit", "planet", "print", "ribbon", "shirt", "skull", "storefront", "telescope", "thermometer", "ticket", "umbrella"]),
    .init(name: "Symbols", iconArray: ["text", "language", "bar-chart", "pie-chart", "ban", "at-circle", "cog", "color-filter", "color-palette", "eyedrop", "color-wand", "create", "crop", "document", "download", "trash", "finger-print", "folder", "checkmark-circle", "heart", "bookmark", "clipboard", "layers", "link", "list", "location", "map", "navigate", "mail", "musical-notes", "notifications", "chatbox", "nuclear", "sunny", "moon", "partly-sunny", "cloud", "rainy", "thunderstorm", "snow", "play", "volume-high", "radio", "pricetag", "school", "shield", "sparkles", "time", "timer", "alarm", "toggle", "funnel", "medical"])
]

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

public enum HabitValueTypes: String, CaseIterable, Hashable {
    case number, time, volume
    
    var name: String {
        switch self {
        case .number:
            return "Number"
        case .time:
            return "Time"
        case .volume:
            return "Volume"
        }
    }
    
    var unit: String {
        switch self {
        case .number:
            return ""
        case .time:
            return "min"
        case .volume:
            return "ml"
        }
    }
}

extension HabitItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitItem> {
        return NSFetchRequest<HabitItem>(entityName: "HabitItem")
    }

    @NSManaged public var amountToDo: Int32
    @NSManaged public var habitDescription: String?
    @NSManaged public var habitName: String
    @NSManaged public var id: UUID
    @NSManaged public var date: Set<HabitCompletionDate>?
    @NSManaged private var resetInterval: String
    @NSManaged public var iconName: String?
    @NSManaged public var iconColorIndex: Int16
    @NSManaged public var habitArchived: Bool
    @NSManaged public var iconColorName: String?
    @NSManaged private var valueType: String?
    @NSManaged public var breakHabit: Bool

    @NSManaged public var tags: NSSet?

    @NSManaged public var notificationDates: NSSet?

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
    
    public var valueTypeEnum: HabitValueTypes {
        get {
            switch self.valueType {
            case "Number":
                return .number
            case "Volume":
                return .volume
            case "Time":
                return .time
            default:
                return .number
            }
        }
        set {
            switch newValue {
            case .number:
                self.valueType = "Number"
            case .volume:
                self.valueType = "Volume"
            case .time:
                self.valueType = "Time"
            }
        }
    }

    /// Array of each date linked to Habit, sorted
//    public var dateArray: [HabitCompletionDate] {
//        let set = date ?? []
//        if !set.isEmpty {
//            return set.sorted {
//                $0.date! < $1.date!
//            }
//        } else {
//            return []
//        }
//    }

    public var notificationArray: [NotificationItem] {
        let set = notificationDates as? Set<NotificationItem> ?? []
        return set.sorted {
            $0.wrappedDate < $1.wrappedDate
        }
    }

    /// Color of the habit´s icon
    public var iconColor: Color {
        return iconColors[Int(iconColorIndex)]
    }

    func deleteHabit() {
        let context = PersistenceController.shared.container.viewContext
        
        #if os(iOS)
        let notificationCenter = UNUserNotificationCenter.current()
        
        let habitNotifications = notificationArray
        
        var notificationIDs: [String] = []
        
        for notification in habitNotifications {
            for weekday in notification.weekdayEnumSet {
                let id = notification.wrappedID.uuidString + " - \(weekday.id)"
                
                notificationIDs.append(id)
            }
            
            context.delete(notification)
        }
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: notificationIDs)
        #endif
        
        self.habitArchived = true
        
        do {
            try context.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func unarchiveHabit() {
        let context = PersistenceController.shared.container.viewContext
        
        self.habitArchived = false
        
        do {
            try context.save()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func deleteHabitPermanently() {
        let context = PersistenceController.shared.container.viewContext
        context.perform {
            context.delete(self)
            
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    /// Function for getting habit's count for its corresponding interval
    func relevantCount(_ date: Date = Date()) -> Int {
        let calendar: Calendar = Calendar.defaultCalendar
        
        var count: Int32 = 0
        
        switch resetIntervalEnum {
        case .daily:
            count = self.date?.first(where: { calendar.isDate($0.date!, equalTo: date, toGranularity: .day) })?.habitValue ?? 0
        case .weekly:
            let dateItemsInWeek = self.date?.filter { calendar.isDate($0.date!, equalTo: date, toGranularity: .weekOfYear) }
            
            if let dateItemsInWeek = dateItemsInWeek {
                for dateItemInWeek in dateItemsInWeek {
                    count += dateItemInWeek.habitValue
                }
            }
        case .monthly:
            let dateItemsInMonth = self.date?.filter { calendar.isDate($0.date!, equalTo: date, toGranularity: .month) }
            
            if let dateItemsInMonth = dateItemsInMonth {
                for dateItemInMonth in dateItemsInMonth {
                    count += dateItemInMonth.habitValue
                }
            }
        }
        
        return Int(count)
    }
    
    func relevantCountDaily(_ date: Date = Date()) -> Int {
        let calendar: Calendar = Calendar.defaultCalendar
        
        var count: Int32 = 0
        
        count = self.date?.first(where: { calendar.isDate($0.date!, equalTo: date, toGranularity: .day) })?.habitValue ?? 0
        
        return Int(count)
    }
    
    func addToHabit(_ value: Int32, date: Date = Date(), context: NSManagedObjectContext) {
        let calendar: Calendar = Calendar.defaultCalendar
        
        let todayItem = self.date?.first(where: { calendar.isDate($0.date!, equalTo: date, toGranularity: .day) })
        
        if let todayItem = todayItem {
            todayItem.habitValue += value
            
            if todayItem.habitValue <= 0 {
                todayItem.habitValue = 0
                
                context.delete(todayItem)
            }
            
            print(todayItem.habitValue)
        } else {
            if value > 0 {
                let newItem = HabitCompletionDate(context: context)
                
                newItem.date = date
                newItem.item = self
                newItem.habitValue = value
            }
        }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    ///Function for getting habit's progress
    func progress(_ date: Date = Date()) -> CGFloat {
        return CGFloat(self.relevantCount(date)) / CGFloat(self.amountToDo)
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

// Extension für Statistics
extension HabitItem {
    func getAverageForInterval(firstDate: Date, lastDate: Date) -> Double {
        let cal = Calendar.defaultCalendar
        
        print("first: \(firstDate)")
        print("last: \(lastDate)")
        
        var amountCompleted = 0
        var intervalsCount = 0
        
        var tempDate = firstDate
        
        while tempDate <= lastDate {
            amountCompleted += self.relevantCount(tempDate)
            intervalsCount += 1
            
            switch self.resetIntervalEnum {
            case .daily:
                tempDate = cal.date(byAdding: .day, value: 1, to: tempDate)!
            case .weekly:
                tempDate = cal.date(byAdding: .weekOfYear, value: 1, to: tempDate)!
            case .monthly:
                tempDate = cal.date(byAdding: .month, value: 1, to: tempDate)!
            }
        }
        
        print("amountCompleted \(amountCompleted)")
        print("intervalsCount \(intervalsCount)")
        
        return Double(amountCompleted) / Double(intervalsCount)
    }
    
    func getPercentageDoneForInterval(firstDate: Date, lastDate: Date) -> Double {
        if self.breakHabit {
            return max(1 - getAverageForInterval(firstDate: firstDate, lastDate: lastDate) / Double(self.amountToDo), 0) * 100
        } else {
            return getAverageForInterval(firstDate: firstDate, lastDate: lastDate) / Double(self.amountToDo) * 100
        }
    }
    
    func getSuccessfulCompletionsForInterval(firstDate: Date, lastDate: Date) -> Int {
        let cal = Calendar.defaultCalendar
        
        var amountCompleted = 0
        
        var tempDate = firstDate
        
        while tempDate <= lastDate {
            let relevantCount = self.relevantCount(tempDate)
            if relevantCount >= Int(self.amountToDo) {
                amountCompleted += 1
            }
            
            switch self.resetIntervalEnum {
            case .daily:
                tempDate = cal.date(byAdding: .day, value: 1, to: tempDate)!
            case .weekly:
                tempDate = cal.date(byAdding: .weekOfYear, value: 1, to: tempDate)!
            case .monthly:
                tempDate = cal.date(byAdding: .month, value: 1, to: tempDate)!
            }
        }
        
        return amountCompleted
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

// MARK: Generated accessors for notificationDates
extension HabitItem {

    @objc(addNotificationDatesObject:)
    @NSManaged public func addToNotificationDates(_ value: NotificationItem)

    @objc(removeNotificationDatesObject:)
    @NSManaged public func removeFromNotificationDates(_ value: NotificationItem)

    @objc(addNotificationDates:)
    @NSManaged public func addToNotificationDates(_ values: NSSet)

    @objc(removeNotificationDates:)
    @NSManaged public func removeFromNotificationDates(_ values: NSSet)

}

extension HabitItem : Identifiable {

}
