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

public let iconChoices = ["man", "woman", "walk", "body", "person", "people", "american-football", "barbell", "baseball", "tennisball", "basketball", "bowling-ball", "fitness", "football", "footsteps", "airplane", "alarm", "aperture", "archive", "at-circle", "bag", "balloon", "ban", "bandage", "bar-chart", "barcode", "basket", "bed", "beer", "bicycle", "boat", "book", "bookmark", "briefcase", "brush", "bug", "build", "bulb", "bus", "business", "cafe", "calculator", "calendar", "call", "camera", "car-sport", "car", "card", "cart", "cash", "chatbox", "checkmark-circle", "clipboard", "cloud", "cloudy", "code-slash", "cog", "color-filter", "color-palette", "color-wand", "create", "crop", "cut", "desktop", "dice", "disc", "document", "download", "ear", "earth", "extension-puzzle", "eye", "eyedrop", "fast-food", "file-tray", "film", "finger-print", "fish", "flag", "flame", "flash", "flask", "flower", "folder", "funnel", "game-controller", "gift", "git-branch", "glasses", "golf", "hammer", "hand-left", "happy", "hardware-chip", "headset", "heart", "hourglass", "ice-cream", "id-card", "image", "journal", "key", "language", "laptop", "layers", "leaf", "library", "link", "list", "location", "lock-closed", "magnet", "mail", "map", "medical", "medkit", "mic", "moon", "musical-notes", "navigate", "newspaper", "notifications", "nuclear", "nutrition", "partly-sunny", "paw", "pencil", "pie-chart", "pint", "pizza", "planet", "play", "pricetag", "print", "qr-code", "radio", "rainy", "reader", "restaurant", "ribbon", "rocket", "rose", "sad", "save", "school", "server", "shield", "shirt", "skull", "snow", "sparkles", "storefront", "subway", "sunny", "telescope", "terminal", "text", "thermometer", "thumbs-down", "thumbs-up", "thunderstorm", "ticket", "time", "timer", "toggle", "trash", "tv", "umbrella", "videocam", "volume-high", "wallet", "watch", "wine"]

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
    @NSManaged public var habitDeleted: Bool
    @NSManaged public var iconColorName: String?
    @NSManaged private var valueType: String?

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
        
        notificationCenter.getPendingNotificationRequests { requests in
            var identifiers = [String]()
            
            let notificationIDStringArray: [String] = self.notificationArray.map { $0.wrappedID.uuidString }
            
            for request in requests {
                if notificationIDStringArray.contains(request.identifier) {
                    identifiers.append(request.identifier)
                }
            }
            
            notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
            
            let notificationIDStrings = self.notificationArray.map { $0.wrappedID.uuidString }
            
            // Vorhandene Notifications löschen
            for notificationIDString in notificationIDStrings {
                if identifiers.contains(notificationIDString) {
                    if let notification = self.notificationArray.first(where: { $0.wrappedID.uuidString == notificationIDString }) {
                        print("deleting notification")
                        
                        context.delete(notification)
                    }
                }
            }
        }
        #endif
        
        self.habitDeleted = true
        
        context.perform {
            do {
                try context.save()
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        
        print(habitDeleted)
    }

    func deleteHabitPermanently() {
        PersistenceController.shared.container.viewContext.delete(self)
    }

    /// Function for getting habit's count for its corresponding interval
    func relevantCount(_ date: Date = Date()) -> Int {
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
        var count: Int32 = 0
        
        switch resetIntervalEnum {
        case .daily:
            count = self.date?.first(where: { Calendar.current.isDate($0.date!, equalTo: date, toGranularity: .day) })?.habitValue ?? 0
        case .weekly:
            let dateItemsInWeek = self.date?.filter { Calendar.current.isDate($0.date!, equalTo: date, toGranularity: .weekOfYear) }
            
            if let dateItemsInWeek = dateItemsInWeek {
                for dateItemInWeek in dateItemsInWeek {
                    count += dateItemInWeek.habitValue
                }
            }
        case .monthly:
            let dateItemsInMonth = self.date?.filter { Calendar.current.isDate($0.date!, equalTo: date, toGranularity: .month) }
            
            if let dateItemsInMonth = dateItemsInMonth {
                for dateItemInMonth in dateItemsInMonth {
                    count += dateItemInMonth.habitValue
                }
            }
        }
        
        return Int(count)
    }
    
    func relevantCountDaily(_ date: Date = Date()) -> Int {
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
        var count: Int32 = 0
        
        count = self.date?.first(where: { Calendar.current.isDate($0.date!, equalTo: date, toGranularity: .day) })?.habitValue ?? 0
        
        return Int(count)
    }
    
    func addToHabit(_ value: Int32, date: Date = Date(), context: NSManagedObjectContext) {
        let todayItem = self.date?.first(where: { Calendar.current.isDate($0.date!, equalTo: date, toGranularity: .day) })
        
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
