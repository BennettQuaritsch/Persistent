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
    
    
    // Name
    @Published var name = ""
    @Published var description = ""
    let uuid: UUID
    
    // Intervall und Art
    @Published var intervalChoice = "Day"
    @Published var buildOrBreakHabit: BuildOrBreakHabitEnum = .buildHabit
    
    // Value Type und Menge
    @Published var valueTypeSelection: HabitValueTypes = .number
    @Published var amountToDo: Int32 = 3
    @Published var valueString: String = ""
    @Published var valueTypeTextFieldSelectedWrapper: Bool = false
    
    // Tags
    @Published var tagSelection = Set<UUID>()
    
    //Werte für das Icon
    @Published var iconChoice: String = "person"
    @Published var colorSelection: Int = 0
    
    @Published var notificationsViewModel = NewNotificationsViewModel()
    
    @Published var validationFailedAlert: Bool = false
    
    var habit: HabitItem?
    
    init() {
        self.uuid = UUID()
    }
    
    init(habit: HabitItem) {
        self.habit = habit
        
        self.name = habit.habitName
        self.uuid = habit.id
        self.description = habit.habitDescription ?? ""
        self.amountToDo = habit.amountToDo
        self.intervalChoice = habit.resetIntervalEnum.getString()
        self.colorSelection = Int(habit.iconColorIndex)
        self.iconChoice = habit.iconName ?? "None"
        
        //self.accentColor = accentColor
        
        var selection = Set<UUID>()
        
        for tag in habit.wrappedTags {
            selection.insert(tag.wrappedId)
        }
        
        self.tagSelection = selection
        
        self.valueString = "\(habit.amountToDo)"
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
        
        if self.amountToDo < 1 {
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
        
        let habitInterval: ResetIntervals
        
        switch intervalChoice {
        case "Day":
            habitInterval = .daily
        case "Week":
            habitInterval = .weekly
        case "Month":
            habitInterval = .monthly
        default:
            habitInterval = .daily
        }
        
        habit.resetIntervalEnum = habitInterval
        
        habit.breakHabit = buildOrBreakHabit.asBool
        
        habit.iconName = iconChoice
        
        habit.iconColorIndex = Int16(colorSelection)
        
        let tags = try? viewContext.fetch(NSFetchRequest<HabitTag>(entityName: "HabitTag"))
        if let tags = tags {
            let chosenTags = tags.filter { tagSelection.contains($0.wrappedId) }
            for tag in chosenTags {
                print(tag)
            }

            habit.tags = NSSet(array: chosenTags)

        }
        
        habit.valueTypeEnum = self.valueTypeSelection
        
        switch valueTypeSelection {
        case .number:
            habit.amountToDo = self.amountToDo
        case .time, .volume:
            if let intValue = Int32(self.valueString) {
                habit.amountToDo = intValue
            }
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
