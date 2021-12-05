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
    let uuid = UUID()
    
    // Intervall
    @Published var intervalChoice = "Day"
    
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
    
    var habit: HabitItem?
    
    init() {
        
    }
    
    init(habit: HabitItem) {
        self.habit = habit
        
        self.name = habit.habitName
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
    
    func saveHabit(habit: HabitItem, viewContext: NSManagedObjectContext, dismiss: DismissAction) {
        habit.id = uuid
        habit.habitName = name
        if description.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            habit.habitDescription = description
        }
        
        habit.habitDeleted = false
        
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
        
        dismiss()
    }
}
