//
//  HabitDetailViewModel.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 19.09.21.
//

import Foundation
import SwiftUI
import CoreData


extension HabitDetailView {
    enum MultipleAddEnum: String, CaseIterable {
        case add
        case remove
    }
    
    class HabitDetailViewModel: ObservableObject {
        let viewContext = PersistenceController.shared.container.viewContext
        
        @Published var habit: HabitItem
        
        init(habit: HabitItem) {
            self.habit = habit
        }
        
        @Published var deleteActionSheet: Bool = false
        @Published var editSheet: Bool = false
        @Published var graphSheet: Bool = false
        @Published var calendarSheet: Bool = false
        
    //    var progress: CGFloat {
    //        return
    //    }

        @Published var chosenDateNumber: Int = 0
        @Published var shownDate: Date = Date()
        
        @Published var multipleAddSelection = MultipleAddEnum.add
        @Published var multipleAddField = ""
        @Published var multipleAddShown = false
        
        func progress() -> CGFloat {
            return CGFloat(habit.relevantCount(shownDate)) / CGFloat(habit.amountToDo)
        }
        
        func addToHabit(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
            withAnimation(.easeInOut) {
                
                let habitObject = context.object(with: habit.objectID) as! HabitItem
                
                habitObject.addToHabit(1, date: shownDate, context: context)
                
                self.objectWillChange.send()
                
                habit.objectWillChange.send()
            }
        }
        
        func removeFromHabit(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
            withAnimation(.easeInOut) {
                
                let habitObject = context.object(with: habit.objectID) as! HabitItem
                
                habitObject.addToHabit(-1, date: shownDate, context: context)
                
                self.objectWillChange.send()
                
                habit.objectWillChange.send()
            }
        }
        
        func addRemoveMultiple() {
            withAnimation(.easeInOut) {
                if let toAdd: Int32 = Int32(multipleAddField) {
                    switch multipleAddSelection {
                    case .add:
                        habit.addToHabit(toAdd, date: shownDate, context: viewContext)
                    case .remove:
                        habit.addToHabit(-toAdd, date: shownDate, context: viewContext)
                    }
                    
                    self.multipleAddField = ""
                    self.multipleAddShown = false
                } else {
                    errorVibration()
                }
                
                self.objectWillChange.send()
                
                habit.objectWillChange.send()
            }
        }
        
        func selectionChanged() {
            #if os(iOS)
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
            #endif
        }
        
        func errorVibration() {
            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            #endif
        }
    }
    
}

