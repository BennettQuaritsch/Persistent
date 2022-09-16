//
//  HabitQuickAddAction+CoreDataProperties.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 01.03.22.
//
//

import Foundation
import CoreData


extension HabitQuickAddAction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<HabitQuickAddAction> {
        return NSFetchRequest<HabitQuickAddAction>(entityName: "HabitQuickAddAction")
    }

    @NSManaged public var id: UUID?
    @NSManaged private var name: String?
    @NSManaged public var value: Int64
    @NSManaged public var habit: HabitItem?
    
    var wrappedID: UUID {
        get {
            return id ?? UUID()
        }
        set {
            id = newValue
        }
    }
    
    public var wrappedValue: Int {
        get {
            return Int(value)
        }
        set {
            value = Int64(newValue)
        }
    }
    
    public func wrappedValueAdjustedForValueType(number: NSNumber, habit: HabitItem) {
        let double = number.doubleValue
        
        switch habit.valueTypeEnum {
        case .volumeLitres:
            value = Int64(double * 1000)
        case .timeHours:
            value = Int64(double * 3600)
        case .timeMinutes:
            value = Int64(double * 3600)
        default:
            value = number.int64Value
        }
    }
    
    var wrappedName: String {
        get {
            return name ?? "Undefined"
        }
        set {
            name = newValue
        }
    }
    
    var valueStingFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        
        formatter.numberStyle = .decimal
        
        return formatter
    }
    
    static func newQuickAddActionForValueType(selectedValueType: HabitValueTypes, id: UUID, name: String, value: NSNumber, habit: HabitItem, context: NSManagedObjectContext) {
        let newAction: HabitQuickAddAction = HabitQuickAddAction(context: context)
        
        let double = value.doubleValue
        
        switch selectedValueType {
        case .volumeLitres, .lengthKilometres:
            newAction.value = Int64(double * 1000)
        case .lengthMiles:
            newAction.value = Int64(double * 1760)
        case .volumeCups:
            newAction.value = Int64(double * 8)
        case .volumeQuarts:
            newAction.value = Int64(double * 32)
        case .timeHours:
            newAction.value = Int64(double * 3600)
        case .timeMinutes:
            newAction.value = Int64(double * 60)
        default:
            newAction.value = value.int64Value
        }
        
        newAction.id = UUID()
        newAction.wrappedName = name
        newAction.habit = habit
        
        do {
            try context.save()
        } catch {
            print("Error")
            
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    
    func valueStringFormatted() -> String {
        if let habit = habit {
            switch habit.valueTypeEnum {
            case .volumeMillilitres, .volumeLitres:
                var string: String = ""
                
                let litres = value / 1000
                let millilitres = value % 1000
                
                if litres != 0 {
                    string += "\(litres)L "
                }
                
                if millilitres != 0 {
                    string += "\(millilitres)mL "
                }
                
                if string.isEmpty {
                    string = "0\(habit.valueTypeEnum.unit) "
                }
                
                string.removeLast()
                
                return string
            case .timeMinutes, .timeHours:
                var string: String = ""
                
                let hour = value / 3600
                let minutes = (value % 3600) / 60
                let seconds = value % 60
                
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
                    string = "0\(habit.valueTypeEnum.unit) "
                }
                
                string.removeLast()
                
                return string
            case .lengthMetres, .lengthKilometres:
                var string: String = ""
                
                let kilometres = value / 1000
                let meters = value % 1000
                
                if kilometres != 0 {
                    string += "\(kilometres)km "
                }
                
                if meters != 0 {
                    string += "\(meters)m "
                }
                
                if string.isEmpty {
                    string = "0\(habit.valueTypeEnum.unit) "
                }
                
                string.removeLast()
                
                return string
            case .lengthYards, .lengthMiles:
                var string: String = ""
                
                let miles = value / 1760
                let yards = value % 1760
                
                if miles != 0 {
                    string += "\(miles)mi "
                }
                
                if yards != 0 {
                    string += "\(yards)yd "
                }
                
                if string.isEmpty {
                    string = "0\(habit.valueTypeEnum.unit) "
                }
                
                string.removeLast()
                
                return string
            case .volumeOunces, .volumeCups, .volumeQuarts:
                var string: String = ""
                
                let quarts = value / 32
                let cups = (value % 32) / 8
                let ounces = value % 8
                
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
                    string = "0\(habit.valueTypeEnum.unit) "
                }
                
                string.removeLast()
                
                return string
            default:
                return "\(value)\(habit.valueTypeEnum.unit)"
            }
            
        }
        return ""
    }

}

extension HabitQuickAddAction : Identifiable {

}
