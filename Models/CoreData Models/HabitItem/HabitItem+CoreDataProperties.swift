//
//  HabitItem+CoreDataProperties.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 29.09.21.
//
//

import Foundation
import CoreData
import SwiftUI

extension Color {
    struct IconColor: Hashable {
        var name: String
        var color: Color
    }
    
    static let iconColors: [IconColor] = [
        .init(name: "Rose", color: Color("rose")),
        .init(name: "Pink", color: Color("pink")),
        .init(name: "Red", color: Color("red")),
        .init(name: "Fiery Orange", color: Color("fiery Orange")),
        .init(name: "Orange", color: Color("orange")),
        .init(name: "Pastel orange", color: Color("pastel orange")),
        .init(name: "Yellow", color: Color("yellow")),
        .init(name: "Grass green", color: Color("grass green")),
        .init(name: "Green", color: Color("green")),
        .init(name: "Greenish Blue", color: Color("greenish blue")),
        .init(name: "Cyan", color: Color("cyan")),
        .init(name: "Teal", color: Color("teal")),
        .init(name: "Blue", color: Color("blue")),
        .init(name: "Indigo", color: Color("indigo")),
        .init(name: "Pastel violet", color: Color("pastel violet")),
        .init(name: "Purple", color: Color("purple")),
        .init(name: "Magenta", color: Color("magenta")),
        .init(name: "Brown", color: Color("brown")),
        .init(name: "Primary", color: Color("primary"))
    ]
}


struct IconSection: Hashable {
    init(name: String, iconArray: [String]) {
        self.name = name
        self.iconArray = iconArray
        
        self.isSelected = UserDefaults.standard.bool(forKey: name + Self.userDefaultsKey)
    }
    
    let name: String
    let iconArray: [String]
    
    var isSelected: Bool
    
    static let userDefaultsKey: String = "IconSectionUserDefaultsKey"
    
    static var sections: [IconSection] {
        return [
            .init(name: "Sport", iconArray: ["walking", "stratching", "exercise", "bicycle", "swimmer", "track-and-field", "boxing", "golf", "javelin-throw", "skateboarding", "canoe", "wakeboarding", "barbell", "bench-press", "deadlift", "curls-with-dumbbells", "pushups", "pullups", "sit-ups", "squats", "football", "american-football", "baseball", "tennisball", "basketball", "volleyball", "bowling-ball", "fitness", ]),
            .init(name: "Food", iconArray: ["restaurant", "nutrition", "pizza", "cheese", "meat", "natural-food", "fast-food", "ice-cream", "pint", "cafe", "beer", "wine", "kawaii-bread", "kawaii-broccoli", "kawaii-french-fries", "kawaii-pizza", "kawaii-soda"]),
            .init(name: "People & Animals", iconArray: ["man", "woman", "body", "person", "people", "happy", "sad", "eye", "footsteps", "hand-left", "ear", "paw", "thumbs-up", "thumbs-down", "cat", "dog", "leash", "clown-fish", "bug"]),
            .init(name: "Chores & Breaking habits", iconArray: ["broom", "vacuuming", "yard-work", "iron", "empty-trash", "recycling", "shopping-cart", "graduation-cap", "todo-list", "no-food", "sugar-free", "no-alcohol" , "no-smoking"]),
            .init(name: "Tech", iconArray: ["imac", "macbook", "tv", "apple-watch", "headset", "mic", "game-controller", "hardware-chip", "git-branch", "qr-code", "camera", "videocam", "aperture", "calculator", "code-slash", "terminal", "save", "disc", "server", ]),
            .init(name: "Objects", iconArray: ["car-sport", "car", "bus", "subway", "airplane", "boat", "rocket", "archive", "bag", "balloon", "bandage", "basket", "bed", "book", "reader", "brush", "pencil", "build", "hammer", "bulb", "business", "calendar", "call", "cart", "wallet", "cash", "card", "briefcase", "cut", "dice", "earth", "extension-puzzle", "file-tray", "film", "flag", "flame", "flash", "flask", "leaf", "flower", "rose", "gift", "glasses", "hourglass", "id-card", "image", "library", "journal", "newspaper", "key", "lock-closed", "magnet", "medkit", "planet", "print", "ribbon", "shirt", "skull", "storefront", "telescope", "thermometer", "ticket", "umbrella"]),
            .init(name: "Symbols", iconArray: ["text", "language", "bar-chart", "pie-chart", "ban", "at-circle", "cog", "color-filter", "color-palette", "eyedrop", "color-wand", "create", "crop", "document", "download", "trash", "finger-print", "folder", "checkmark-circle", "heart", "bookmark", "clipboard", "layers", "link", "list", "location", "map", "navigate", "mail", "musical-notes", "notifications", "chatbox", "nuclear", "sunny", "moon", "partly-sunny", "cloud", "rainy", "thunderstorm", "snow", "play", "volume-high", "radio", "pricetag", "school", "shield", "sparkles", "time", "timer", "alarm", "toggle", "funnel", "medical"])
        ]
    }
}

public enum ResetIntervals: CaseIterable, Hashable {
    case daily, weekly, monthly

    var name: String {
        switch self {
        case .daily:
            return "Daily"
        case .weekly:
            return "Weekly"
        case .monthly:
            return "Monthly"
        }
    }
    
    var noun: String {
        switch self {
        case .daily:
            return "day"
        case .weekly:
            return "week"
        case .monthly:
            return "month"
        }
    }
}

public enum HabitValueTypes: String, CaseIterable, Hashable {
    case number, timeMinutes, timeHours, volumeMillilitres, volumeLitres, volumeOunces, volumeCups, volumeQuarts, lengthMetres, lengthKilometres, lengthYards, lengthMiles
    
    var name: String {
        switch self {
        case .number:
            return "Number"
        case .timeMinutes:
            return "TimeMinutes"
        case .timeHours:
            return "TimeHours"
        case .volumeMillilitres:
            return "VolumeMillilitres"
        case .volumeLitres:
            return "VolumeLitres"
        case .volumeOunces:
            return "VolumeOunces"
        case .volumeCups:
            return "VolumeCups"
        case .volumeQuarts:
            return "VolumeQuarts"
        case .lengthMetres:
            return "LengthMetres"
        case .lengthKilometres:
            return "LengthKilometres"
        case .lengthYards:
            return "LengthYards"
        case .lengthMiles:
            return "LengthMiles"

        }
    }
    
    var localizedNameString: String {
        switch self {
        case .number:
            return "Number"
        case .timeMinutes:
            return "Minutes"
        case .timeHours:
            return "Hours"
        case .volumeMillilitres:
            return "Millilitres"
        case .volumeLitres:
            return "Litres"
        case .volumeOunces:
            return "Ounces"
        case .volumeCups:
            return "Cups"
        case .volumeQuarts:
            return "Quarts"
        case .lengthMetres:
            return "Metres"
        case .lengthKilometres:
            return "Kilometres"
        case .lengthYards:
            return "Yards"
        case .lengthMiles:
            return "Miles"
        }
    }
    
    var unit: String {
        switch self {
        case .number:
            return ""
        case .timeMinutes:
            return "min"
        case .timeHours:
            return "h"
        case .volumeMillilitres:
            return "mL"
        case .volumeLitres:
            return "L"
        case .volumeOunces:
            return "oz"
        case .volumeCups:
            return "cups"
        case .volumeQuarts:
            return "qt"
        case .lengthMetres:
            return "m"
        case .lengthKilometres:
            return "km"
        case .lengthYards:
            return "yd"
        case .lengthMiles:
            return "mi"
        }
    }
    
    init(from string: String?) {
        switch string {
        case "Number":
            self = .number
        case "TimeMinutes":
            self = .timeMinutes
        case "TimeHours":
            self = .timeHours
        case "VolumeMillilitres":
            self = .volumeMillilitres
        case "VolumeLitres":
            self = .volumeLitres
        case "VolumeOunces":
            self = .volumeOunces
        case "VolumeCups":
            self = .volumeCups
        case "VolumeQuarts":
            self = .volumeQuarts
        case "LengthMetres":
            self = .lengthMetres
        case "LengthKilometres":
            self = .lengthKilometres
        case "LengthYards":
            self = .lengthYards
        case "LengthMiles":
            self = .lengthMiles
        default:
            self = .number
        }
    }
    
    var comparableTypes: [HabitValueTypes] {
        switch self {
        case .number:
            return [.number]
        case .timeMinutes, .timeHours:
            return [.timeMinutes, .timeHours]
        case .volumeMillilitres, .volumeLitres:
            return [.volumeMillilitres, .volumeLitres]
        case .volumeOunces, .volumeCups, .volumeQuarts:
            return [.volumeOunces, .volumeCups, .volumeQuarts]
        case .lengthMetres, .lengthKilometres:
            return [.lengthMetres, .lengthKilometres]
        case .lengthYards, .lengthMiles:
            return [.lengthYards, .lengthMiles]
        }
    }
    
    static func rawAmountToDo(for number: Double, valueType: HabitValueTypes) -> Double {
        switch valueType {
        case .volumeLitres, .lengthKilometres:
            return Double(number) * 1000
        case .timeMinutes:
            return Double(number) * 60
        case .timeHours:
            return Double(number) * 3600
        case .lengthMiles:
            return Double(number) * 1760
        case .volumeCups:
            return number * 8
        case .volumeQuarts:
            return number * 32
        default:
            return number
        }
    }
    
//    static func changeValue(_ value: Int, for first: HabitValueTypes, and second: HabitValueTypes) -> Int {
//        if first.comparableTypes.contains(second) {
//            return value
//        }
//        
//        if first.comparableTypes.contains(.lengthMetres) && second.comparableTypes.contains(.lengthYards)
//    }
}

extension HabitItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitItem> {
        return NSFetchRequest<HabitItem>(entityName: "HabitItem")
    }

    @NSManaged public var amountToDo: Int64
    
    public var wrappedAmountToDo: Int {
        get {
            return Int(amountToDo)
        }
        set {
            amountToDo = Int64(newValue)
        }
    }
    
    func amountToDoForType() -> Double {
        switch self.valueTypeEnum {
        case .volumeLitres, .lengthKilometres:
            return Double(amountToDo) / 1000
        case .timeMinutes:
            return Double(amountToDo) / 60
        case .timeHours:
            return Double(amountToDo) / 3600
        case .lengthMiles:
            return Double(amountToDo) / 1760
        case .volumeCups:
            return Double(amountToDo) / 8
        case .volumeQuarts:
            return Double(amountToDo) / 32
        default:
            return Double(amountToDo)
        }
    }
    
    func amountToDoString() -> String {
        let count = amountToDo
        
        switch self.valueTypeEnum {
        case .volumeMillilitres, .volumeLitres:
            var string: String = ""
            
            let litres = count / 1000
            let millilitres = count % 1000
            
            if litres != 0 {
                string += "\(litres) litres "
            }
            
            if millilitres != 0 {
                string += "\(millilitres) millilitres "
            }
            
            if string.isEmpty {
                string = "0\(self.valueTypeEnum.unit) "
            }
            
            string.removeLast()
            
            return string
        case .timeMinutes, .timeHours:
            var string: String = ""
            
            print("count: \(count)")
            
            let hour = count / 3600
            let minutes = (count % 3600) / 60
            let seconds = count % 60
            
            if hour != 0 {
                string += "\(hour) hours "
            }
            
            if minutes != 0 {
                string += "\(!string.isEmpty ? "and " : "")\(minutes) minutes "
            }
            
            if seconds != 0 {
                string += "\(!string.isEmpty ? "and " : "")\(seconds) seconds "
            }
            
            if string.isEmpty {
                string = "0\(self.valueTypeEnum.unit) "
            }
            
            string.removeLast()
            
            return string
        case .lengthMetres, .lengthKilometres:
            var string: String = ""
            
            let kilometres = count / 1000
            let meters = count % 1000
            
            if kilometres != 0 {
                string += "\(kilometres) kilometres "
            }
            
            if meters != 0 {
                string += "\(meters) metres "
            }
            
            if string.isEmpty {
                string = "0\(self.valueTypeEnum.unit) "
            }
            
            string.removeLast()
            
            return string
        case .lengthYards, .lengthMiles:
            var string: String = ""
            
            let miles = count / 1760
            let yards = count % 1760
            
            if miles != 0 {
                string += "\(miles) miles "
            }
            
            if yards != 0 {
                string += "\(yards) yards "
            }
            
            if string.isEmpty {
                string = "0\(self.valueTypeEnum.unit) "
            }
            
            string.removeLast()
            
            return string
        case .volumeOunces, .volumeCups, .volumeQuarts:
            var string: String = ""
            
            let quarts = count / 32
            let cups = (count % 32) / 8
            let ounces = count % 8
            
            if quarts != 0 {
                string += "\(quarts) quarts "
            }
            
            if cups != 0 {
                string += "\(cups) cups "
            }
            
            if ounces != 0 {
                string += "\(ounces) ounces "
            }
            
            if string.isEmpty {
                string = "0\(self.valueTypeEnum.unit) "
            }
            
            string.removeLast()
            
            return string
        default:
            return "\(count)\(self.valueTypeEnum.unit)"
        }
    }
    
//    @NSManaged public var habitDescription: String?
    @NSManaged public var habitName: String
    @NSManaged public var id: UUID
    @NSManaged public var date: Set<HabitCompletionDate>?
    @NSManaged private var resetInterval: String
    @NSManaged private var standardAddValue: Int64
    
    public var wrappedStandardAddValue: Int {
        get {
            return Int(standardAddValue)
        }
        set {
            self.standardAddValue = Int64(newValue)
        }
    }
    
    func standardAddValueForType() -> Double {
        switch self.valueTypeEnum {
        case .volumeLitres, .lengthKilometres:
            return Double(standardAddValue) / 1000
        case .timeMinutes:
            return Double(standardAddValue) / 60
        case .timeHours:
            return Double(standardAddValue) / 3600
        case .lengthMiles:
            return Double(standardAddValue) / 1760
        case .volumeCups:
            return Double(standardAddValue) / 8
        case .volumeQuarts:
            return Double(standardAddValue) / 32
        default:
            return Double(standardAddValue)
        }
    }
    
    public func setStandardAddValue(number: NSNumber) {
        switch self.valueTypeEnum {
        case .volumeLitres, .lengthKilometres:
            self.standardAddValue = Int64(number.doubleValue * 1000)
        case .timeMinutes:
            self.standardAddValue = Int64(number.doubleValue * 60)
        case .timeHours:
            self.standardAddValue = Int64(number.doubleValue * 3600)
            print("test: \(Int64(number.doubleValue * 3600))")
        case .lengthMiles:
            self.standardAddValue = Int64(number.doubleValue * 1760)
        case .volumeCups:
            self.standardAddValue = Int64(number.doubleValue * 8)
        case .volumeQuarts:
            self.standardAddValue = Int64(number.doubleValue * 32)
        default:
            self.standardAddValue = (number.int64Value > 0 ? number.int64Value : 1)
        }
    }
    
    // Icons
    @NSManaged public var iconName: String?
    @NSManaged private var iconColorName: String?
    
    @NSManaged public var habitArchived: Bool
    @NSManaged private var valueType: String?
    @NSManaged public var breakHabit: Bool
    
    @NSManaged public var timerStartDate: Date?

    @NSManaged public var tags: NSSet?

    @NSManaged public var notificationDates: NSSet?
    
    // Habit Quick Actions
    @NSManaged private var quickAddActions: NSSet?
    
    public var quickAddActionsArray: [HabitQuickAddAction] {
        let set = quickAddActions as? Set<HabitQuickAddAction> ?? []
        
        return set.sorted { (lhs, rhs) in
            if lhs.value == rhs.value {
                return lhs.wrappedName < rhs.wrappedName
            }
            
            return lhs.value < rhs.value
        }
    }

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
            return HabitValueTypes(from: self.valueType)
        }
        set {
            self.valueType = newValue.name
        }
    }

    public var notificationArray: [NotificationItem] {
        let set = notificationDates as? Set<NotificationItem> ?? []
        return set.sorted {
            $0.wrappedDate < $1.wrappedDate
        }
    }

    /// Color of the habit´s icon
    public var iconColor: Color {
//        return iconColors[Int(iconColorIndex)]
        guard let color = Color.iconColors.first(where: { $0.name == iconColorName }) else { return Color.iconColors.first!.color }
        
        return color.color
    }
    
    public var wrappedIconColorName: String {
        get {
            return self.iconColorName ?? Color.iconColors.first!.name
        }
        set {
            self.iconColorName = newValue
        }
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

    func deleteHabitPermanently(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        
        context.delete(self)
        
        do {
            try context.save()
        } catch {
            print("Error")
            
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    /// Function for getting habit's count for its corresponding interval
    func relevantCount(_ date: Date = Date()) -> Int {
        let calendar: Calendar = Calendar.defaultCalendar
        
        var count: Int = 0
        
        switch resetIntervalEnum {
        case .daily:
            count = self.date?.first(where: { calendar.isDate($0.date!, equalTo: date, toGranularity: .day) })?.wrappedHabitValue ?? 0
        case .weekly:
            let dateItemsInWeek = self.date?.filter { calendar.isDate($0.date!, equalTo: date, toGranularity: .weekOfYear) }
            
            if let dateItemsInWeek = dateItemsInWeek {
                for dateItemInWeek in dateItemsInWeek {
                    count += dateItemInWeek.wrappedHabitValue
                }
            }
        case .monthly:
            let dateItemsInMonth = self.date?.filter { calendar.isDate($0.date!, equalTo: date, toGranularity: .month) }
            
            if let dateItemsInMonth = dateItemsInMonth {
                for dateItemInMonth in dateItemsInMonth {
                    count += dateItemInMonth.wrappedHabitValue
                }
            }
        }
        
        return count
    }
    
    func relevantCountForType(_ date: Date = Date()) -> Double {
        let count = relevantCount(date)
        
        switch self.valueTypeEnum {
        case .volumeLitres:
            return Double(count) / 1000
        case .volumeCups:
            return Double(count) / 8
        case .volumeQuarts:
            return Double(count) / 32
        case .timeMinutes:
            return Double(count) / 60
        case .timeHours:
            return Double(count) / 3600
        case .lengthKilometres:
            return Double(count) / 1000
        case .lengthMiles:
            return Double(count) / 1760
        default:
            return Double(count)
        }
    }
    
    func relevantCountText(_ date: Date = Date()) -> String {
        let count = relevantCount(date)
        
        switch self.valueTypeEnum {
        case .volumeMillilitres, .volumeLitres:
            var string: String = ""
            
            let litres = count / 1000
            let millilitres = count % 1000
            
            if litres != 0 {
                string += "\(litres)L "
            }
            
            if millilitres != 0 {
                string += "\(millilitres)mL "
            }
            
            if string.isEmpty {
                string = "0\(self.valueTypeEnum.unit) "
            }
            
            string.removeLast()
            
            return string
        case .timeMinutes, .timeHours:
            var string: String = ""
            
            let hour = count / 3600
            let minutes = (count % 3600) / 60
            let seconds = count % 60
            
            if hour != 0 {
                string += "\(hour)h "
            }
            
            if minutes != 0 {
                string += "\(minutes)min "
            }
            
            if seconds != 0 {
                string += "\(seconds)s "
            }
            
            if string.isEmpty {
                string = "0\(self.valueTypeEnum.unit) "
            }
            
            string.removeLast()
            
            return string
        case .lengthMetres, .lengthKilometres:
            var string: String = ""
            
            let kilometres = count / 1000
            let metres = count % 1000
            
            if kilometres != 0 {
                string += "\(kilometres)kM "
            }
            
            if metres != 0 {
                string += "\(metres)m "
            }
            
            if string.isEmpty {
                string = "0\(self.valueTypeEnum.unit) "
            }
            
            string.removeLast()
            
            return string
        case .lengthYards, .lengthMiles:
            var string: String = ""
            
            let miles = count / 1760
            let yards = count % 1760
            
            if miles != 0 {
                string += "\(miles)mi "
            }
            
            if yards != 0 {
                string += "\(yards)yd "
            }
            
            if string.isEmpty {
                string = "0\(self.valueTypeEnum.unit) "
            }
            
            string.removeLast()
            
            return string
        case .volumeOunces, .volumeCups, .volumeQuarts:
            var string: String = ""
            
            let quarts = count / 32
            let cups = (count % 32) / 8
            let ounces = count % 8
            
            if quarts != 0 {
                string += "\(quarts)qt "
            }
            
            if cups != 0 {
                string += "\(cups)cups "
            }
            
            if ounces != 0 {
                string += "\(ounces)oz "
            }
            
            if string.isEmpty {
                string = "0\(self.valueTypeEnum.unit) "
            }
            
            string.removeLast()
            
            return string
        default:
            return "\(count)\(self.valueTypeEnum.unit)"
        }
    }
    
    func relevantCountTextSmall(_ date: Date = Date()) -> String {
        let count = relevantCount(date)
        
        switch self.valueTypeEnum {
        case .volumeMillilitres, .volumeLitres:
            let litres = count / 1000
            let millilitres = count % 1000
            
            if litres != 0 {
                return "\(litres)L"
            }
            
            if millilitres != 0 {
                return "\(millilitres)mL"
            }
            
            return "0\(self.valueTypeEnum.unit)"
        case .timeMinutes, .timeHours:
            let hour = count / 3600
            let minutes = (count % 3600) / 60
            let seconds = count % 60
            
            if hour != 0 {
                return "\(hour)h "
            }
            
            if minutes != 0 {
                return "\(minutes)min "
            }
            
            if seconds != 0 {
                return "\(seconds)s "
            }
            
            return "0\(self.valueTypeEnum.unit)"
        case .lengthMetres, .lengthKilometres:
            let kilometres = count / 1000
            let metres = count % 1000
            
            if kilometres != 0 {
                return "\(kilometres)km"
            }
            
            if metres != 0 {
                return "\(metres)m"
            }
            
            return "0\(self.valueTypeEnum.unit)"
        case .lengthYards, .lengthMiles:
            let miles = count / 1760
            let yards = count % 1760
            
            if miles != 0 {
                return "\(miles)mi"
            }
            
            if yards != 0 {
                return "\(yards)yd"
            }
            
            return "0\(self.valueTypeEnum.unit)"
        case .volumeOunces, .volumeCups, .volumeQuarts:
            let quarts = count / 32
            let cups = (count % 32) / 8
            let ounces = count % 8
            
            if quarts != 0 {
                return "\(quarts)qt"
            }
            
            if cups != 0 {
                return "\(cups)c"
            }
            
            if ounces != 0 {
                return "\(ounces)oz"
            }
            
            return "0\(self.valueTypeEnum.unit)"
        default:
            return "\(count)\(self.valueTypeEnum.unit)"
        }
    }
    
    
    
    
    
    
    func relevantCountDaily(_ date: Date = Date(), adjusted: Bool = false) -> Int {
        let calendar: Calendar = Calendar.defaultCalendar
        
        var count: Int = 0
        
        count = self.date?.first(where: { calendar.isDate($0.date!, equalTo: date, toGranularity: .day) })?.wrappedHabitValue ?? 0
        
        return count
    }
    
    func addToHabitForValueType(_ value: Double, valueType: HabitValueTypes? = nil, date: Date = Date(), context: NSManagedObjectContext, appViewModel: AppViewModel? = nil) {
        
        let valueTypeSwitch: HabitValueTypes
        
        if let valueType = valueType {
            valueTypeSwitch = valueType
        } else {
            valueTypeSwitch = self.valueTypeEnum
        }
        
        var toAdd: Int
        switch valueTypeSwitch {
        case .timeHours:
            toAdd = Int(value * 3600)
        case.timeMinutes:
            toAdd = Int(value * 60)
        case .volumeLitres, .lengthKilometres:
            toAdd = Int(value * 1000)
        case .lengthMiles:
            toAdd = Int(value * 1760)
        case .volumeCups:
            toAdd = Int(value * 8)
        case .volumeQuarts:
            toAdd = Int(value * 32)
        default:
            toAdd = Int(value)
        }
        
        addToHabit(toAdd, date: date, context: context, appViewModel: appViewModel)
    }
    
    func addToHabit(_ value: Int, date: Date = Date(), context: NSManagedObjectContext, appViewModel: AppViewModel? = nil) {
        let calendar: Calendar = Calendar.defaultCalendar
        
        let todayItem = self.date?.first(where: { calendar.isDate($0.date!, equalTo: date, toGranularity: .day) })
        
        if let todayItem = todayItem {
            todayItem.wrappedHabitValue += value
            
            if todayItem.habitValue <= 0 {
                context.delete(todayItem)
            }
        } else {
            if value > 0 {
                let newItem = HabitCompletionDate(context: context)
                
                newItem.date = date
                newItem.item = self
                newItem.wrappedHabitValue = value
            }
        }
        
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            guard let appViewModel = appViewModel else { fatalError("Unresolved error \(nsError), \(nsError.userInfo)") }
            
            appViewModel.saveErrorActionSheet = true
            
            context.rollback()
        }
    }
    
    func addToHabitAdjusted(_ value: Int, date: Date = Date(), context: NSManagedObjectContext, appViewModel: AppViewModel? = nil) {
        let adjustedDate: Date = date.adjustedForNightOwl()
        addToHabit(value, date: adjustedDate, context: context, appViewModel: appViewModel)
    }

    ///Function for getting habit's progress
    func progress(_ date: Date = Date()) -> CGFloat {
//        print("habit: \(self.habitName), count: \(self.relevantCount(date)), amount: \(self.amountToDo), progerss: \(CGFloat(self.relevantCount(date)) / CGFloat(self.amountToDo))")
        
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

    func setAmountToDoForType(number: NSNumber) {
        switch self.valueTypeEnum {
        case .volumeLitres, .lengthKilometres:
            self.amountToDo = Int64(number.doubleValue * 1000)
        case .timeMinutes:
            self.amountToDo = Int64(number.doubleValue * 60)
        case .timeHours:
            self.amountToDo = Int64(number.doubleValue * 3600)
            print("test: \(Int64(number.doubleValue * 3600))")
        case .lengthMiles:
            self.amountToDo = Int64(number.doubleValue * 1760)
        case .volumeCups:
            self.amountToDo = Int64(number.doubleValue * 8)
        case .volumeQuarts:
            self.amountToDo = Int64(number.doubleValue * 32)
        default:
            self.amountToDo = (number.int64Value > 0 ? number.int64Value : 1)
        }
    }
    
}

// Extension für Statistics
extension HabitItem {
    func getAverageForInterval(firstDate: Date, lastDate: Date) -> Double {
        let cal = Calendar.defaultCalendar
        
        var amountCompleted: Int = 0
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
            if relevantCount >= self.amountToDo {
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

// MARK: Extension for testHabit
extension HabitItem {
    /// Test habit defined in preview container
    static var testHabit: HabitItem {
        let moc = PersistenceController.preview.container.viewContext
    
        let habit = HabitItem(context: moc)
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
        
        let date = HabitCompletionDate(context: moc)
        date.date = Date()
        date.item = habit
        date.habitValue = 5
        
        let quickAdd = HabitQuickAddAction(context: moc)
        quickAdd.id = UUID()
        quickAdd.wrappedName = "Test"
        quickAdd.value = 3
        quickAdd.habit = habit
        
        return habit
    }
}
