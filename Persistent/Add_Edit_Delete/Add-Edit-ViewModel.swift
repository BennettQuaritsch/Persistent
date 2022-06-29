//
//  Add-Edit-ViewModel.swift.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 22.11.21.
//

import Foundation
import SwiftUI
import CoreData



class AddEditViewModel: ObservableObject {
    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 3
        return formatter
    }
    
    
    // Name
    @Published var name = ""
    let uuid: UUID
    
    // Intervall und Art
    @Published var intervalChoice: ResetIntervals = .daily
    @Published var buildOrBreakHabit: BuildOrBreakHabitEnum = .buildHabit
    
    // Value Type und Menge
    @Published var valueTypeSelection: HabitValueTypes = .number
    @Published var amountToDo: Int = 3
    @Published var valueString: String = ""
    @Published var valueTypeTextFieldSelectedWrapper: Bool = false
    @Published var standardAddValueTextField: String = ""
    
    // Tags
    @Published var tagSelection = Set<UUID>()
    
    //Werte für das Icon
    @Published var iconChoice: String = IconSection.sections.randomElement()?.iconArray.randomElement() ?? "person"
    @Published var colorSelection: Int = 0
    @Published var iconColorName: String
    
    @Published var notificationsViewModel = NewNotificationsViewModel()
    
    @Published var validationFailedAlert: Bool = false
    
    var habit: HabitItem?
    
    init() {
        self.uuid = UUID()
        self.iconColorName = Color.iconColors.randomElement()?.name ?? "Primary"
    }
    
    init(habit: HabitItem) {
        self.habit = habit
        
        self.name = habit.habitName
        self.uuid = habit.id
        
        self.amountToDo = habit.wrappedAmountToDo
        print("amount: \(habit.amountToDo)")
        self.valueString = NumberFormatter.habitValueNumberFormatter.string(from: habit.amountToDoForType() as NSNumber) ?? ""
        self.standardAddValueTextField = NumberFormatter.habitValueNumberFormatter.string(from: habit.standardAddValueForType() as NSNumber) ?? ""
        
        self.intervalChoice = habit.resetIntervalEnum
        self.iconChoice = habit.iconName ?? "None"
        self.iconColorName = habit.wrappedIconColorName
        self.buildOrBreakHabit = BuildOrBreakHabitEnum(habit.breakHabit)
        
        //self.accentColor = accentColor
        
        var selection = Set<UUID>()
        
        for tag in habit.wrappedTags {
            selection.insert(tag.wrappedId)
        }
        
        self.tagSelection = selection

        self.valueTypeSelection =  habit.valueTypeEnum
    }
    
    // Vibration
    #if os(iOS)
    func habitAddedVibration() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    #endif
    
    func addHabit(viewContext: NSManagedObjectContext, dismiss: DismissAction) {
        do {
            try validateHabit()
        } catch {
            errorVibration()
            
            self.validationFailedAlert = true
            
            return
        }
        
        let newhabit = HabitItem(context: viewContext)
        
        saveHabit(habit: newhabit, viewContext: viewContext, dismiss: dismiss)
        
        #if os(iOS)
        //notificationsViewModel.addNotification(habit: newhabit, context: viewContext)
        notificationsViewModel.addNotifications(habit: newhabit, moc: viewContext)
        
        habitAddedVibration()
        #endif
        
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    func editHabit(viewContext: NSManagedObjectContext, dismiss: DismissAction) {
        if let habit = self.habit {
            do {
                try validateHabit()
            } catch {
                errorVibration()
                
                self.validationFailedAlert = true
                
                return
            }
            
            saveHabit(habit: habit, viewContext: viewContext, dismiss: dismiss)
            
            #if os(iOS)
            //notificationsViewModel.addNotification(habit: newhabit, context: viewContext)
            //notificationsViewModel.editNotifications(habit: habit, context: viewContext)
            notificationsViewModel.editNotifications(habit: habit, moc: viewContext)

            habitAddedVibration()
            #endif
            
            if viewContext.hasChanges {
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }
    
    private enum HabitValidationError: Error {
        case validationError
    }
    
    private func validateHabit() throws {
        if self.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw HabitValidationError.validationError
        }
        
        guard let number = numberFormatter.number(from: self.valueString) else  { throw HabitValidationError.validationError }
        
        if number.decimalValue <= 0 {
            throw HabitValidationError.validationError
        }
        
        let rawAmountToDo = HabitValueTypes.rawAmountToDo(for: number.doubleValue, valueType: valueTypeSelection)
        guard rawAmountToDo <= Double(Int64.max) && rawAmountToDo >= Double(Int64.min) else {
            throw HabitValidationError.validationError
        }
        
        for notificationObject in self.notificationsViewModel.notifcationArray {
            if notificationObject.weekdays.isEmpty {
                throw HabitValidationError.validationError
            }
        }
    }
    
    func saveHabit(habit: HabitItem, viewContext: NSManagedObjectContext, dismiss: DismissAction) {
        
        habit.id = uuid
        habit.habitName = name
        
        habit.habitArchived = false
        
        habit.resetIntervalEnum = intervalChoice
        
        habit.breakHabit = buildOrBreakHabit.asBool
        
        habit.iconName = iconChoice
        
        habit.wrappedIconColorName = self.iconColorName
        
        let tags = try? viewContext.fetch(NSFetchRequest<HabitTag>(entityName: "HabitTag"))
        if let tags = tags {
            let chosenTags = tags.filter { tagSelection.contains($0.wrappedId) }
            for tag in chosenTags {
                print(tag)
            }

            habit.tags = NSSet(array: chosenTags)

        }
        
        habit.valueTypeEnum = self.valueTypeSelection
        
        if let number = numberFormatter.number(from: self.valueString) {
            print("number: \(number.doubleValue)")
            habit.setAmountToDoForType(number: number)
        } else {
            habit.wrappedAmountToDo = 1
        }
        
        // Set StandardAddValue
        if let number = numberFormatter.number(from: self.standardAddValueTextField) {
            print("standard:", number.doubleValue)
            habit.setStandardAddValue(number: number)
        } else {
            habit.setStandardAddValue(number: 1)
        }
        
        
//        do {
//            try viewContext.save()
//        } catch {
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
//
        dismiss()
    }
}
