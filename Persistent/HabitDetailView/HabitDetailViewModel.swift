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
        
        func addToHabit() {
            withAnimation(.easeInOut) {
                let newhabit = HabitCompletionDate(context: viewContext)
                newhabit.date = shownDate
                newhabit.item = habit
                
                do {
                    try viewContext.save()
                    selectionChanged()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
        
        func removeFromHabit() {
            withAnimation(.easeInOut) {
    //            let habitObject = habit.date?.sortedArray(using: [NSSortDescriptor(keyPath: \HabitCompletionDate.date, ascending: true)]).last
                
                if let habitObject = habit.dateArray.last(where: { Calendar.current.isDate($0.date!, equalTo: shownDate, toGranularity: .day) }) {
                    viewContext.delete(habitObject as NSManagedObject)
                    selectionChanged()
                } else {
                    errorVibration()
                }
                
                do {
                    try viewContext.save()
                    
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
        
        func selectionChanged() {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
        
        func errorVibration() {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
}

