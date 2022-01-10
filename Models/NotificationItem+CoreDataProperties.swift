//
//  NotificationItem+CoreDataProperties.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 28.09.21.
//
//

import Foundation
import CoreData

extension Calendar {
    static var defaultCalendar: Calendar {
        var calendar = Calendar.current
        let prefLanguage = Locale.preferredLanguages[0]
        calendar.locale = .init(identifier: prefLanguage)
        
        if let weekdaySelectionEnumData = UserDefaults.standard.object(forKey: Calendar.FirstWeekdayEnum.userDefaultsString) as? Data {
            let decoder = JSONDecoder()
            if let decodedWeekdaySelection = try? decoder.decode(Calendar.FirstWeekdayEnum.self, from: weekdaySelectionEnumData) {
                calendar.firstWeekday = decodedWeekdaySelection.id
            } else {
                calendar.firstWeekday = FirstWeekdayEnum.monday.id
            }
        } else {
            calendar.firstWeekday = FirstWeekdayEnum.monday.id
        }
        
        return calendar
    }
    
    enum FirstWeekdayEnum: String, Codable, CaseIterable {
        case sunday = "Sunday"
        case monday = "Monday"
        
        var id: Int {
            switch self {
            case .sunday:
                return 1
            case .monday:
                return 2
            }
        }
        
        static let userDefaultsString = "firstWeekdayEnum"
    }
}

public enum WeekdayEnum {
    init(index: Int) {
        switch index {
        case 1:
            self = .monday
        case 2:
            self = .tuesday
        case 3:
            self = .wednesday
        case 4:
            self = .thursday
        case 5:
            self = .friday
        case 6:
            self = .saturday
        case 7, 0:
            self = .sunday
        default:
            self = .monday
        }
    }
    
    init(date: Date) {
        let calendar: Calendar = Calendar.defaultCalendar
        
        let weekday = ((calendar.component(.weekday, from: date) - 1) + (calendar.firstWeekday - 1)) % 7
        
        self.init(index: weekday)
    }
    
    case monday, tuesday, wednesday, thursday, friday, saturday, sunday
    
    var id: Int {
        switch self {
        case .monday:
            return 1
        case .tuesday:
            return 2
        case .wednesday:
            return 3
        case .thursday:
            return 4
        case .friday:
            return 5
        case .saturday:
            return 6
        case .sunday:
            return 7
        }
    }
}

extension NotificationItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotificationItem> {
        return NSFetchRequest<NotificationItem>(entityName: "NotificationItem")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged private var weekdayIntSet: Set<Int>?
    @NSManaged private var message: String?
    
    @NSManaged public var habit: HabitItem?
    
    public var wrappedID: UUID {
        get {
            return id ?? UUID()
        }
        set {
            id = newValue
        }
    }
    
    public var wrappedIntSet: Set<Int> {
        get {
            return self.weekdayIntSet ?? []
        }
        set {
            self.weekdayIntSet = newValue
        }
    }
    
    public var wrappedDate: Date {
        get {
            return date ?? Date()
        }
        set {
            date = newValue
        }
    }
    
    public var wrappedHabit: HabitItem {
        get {
            return habit ?? HabitItem()
        }
        set {
            habit = newValue
        }
    }
    
    public var wrappedMessage: String {
        get {
            message ?? "Think of your habit!"
        }
        set {
            message = newValue
        }
    }
    
    public var weekdayEnumSet: Set<WeekdayEnum> {
        get {
            if let weekdayIntSet = self.weekdayIntSet {
                return Set(weekdayIntSet.map { WeekdayEnum(index: $0) })
            } else {
                return []
            }
        }
        set {
            self.weekdayIntSet = Set(newValue.map { $0.id })
        }
    }

}

extension NotificationItem : Identifiable {

}
