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
    
    class EditViewShownModel: ObservableObject {
        @Published var editSheet: Bool = false
    }
    
    class HabitDetailViewModel: ObservableObject {
        let viewContext = PersistenceController.shared.container.viewContext
        var appViewModel: AppViewModel?
        
        @Published var habit: HabitItem
        
        @Published var selectedHabitTypeForMultipleAdd: HabitValueTypes
        
//        var listViewModel: ListViewModel
        
        init(habit: HabitItem) {
            self.habit = habit
            selectedHabitTypeForMultipleAdd = habit.valueTypeEnum
        }
        
        @Published var deleteActionSheet: Bool = false
        @Published var editSheet: Bool = false
        @Published var graphSheet: Bool = false
        @Published var calendarSheet: Bool = false
        
    //    var progress: CGFloat {
    //        return
    //    }

        @Published var chosenDateNumber: Int = 0
        @Published var shownDate: Date = Date().adjustedForNightOwl()
        
        @Published var multipleAddSelection = MultipleAddEnum.add
        @Published var multipleAddField = ""
        @Published var multipleAddShown = false
        
//        func progress() -> CGFloat {
//            return CGFloat(habit.relevantCount(shownDate)) / CGFloat(habit.amountToDo)
//        }
        
        func addToHabit(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
            withAnimation(.easeInOut) {
                
                let habitObject = context.object(with: habit.objectID) as! HabitItem
                
                print("currentHabit: \(habitObject.habitName)")
                
                habitObject.addToHabit(habitObject.wrappedStandardAddValue, date: shownDate, context: context, appViewModel: appViewModel)
                
                self.objectWillChange.send()
                
                habit.objectWillChange.send()
                
//                listViewModel.objectWillChange.send()
            }
            
            selectionChangedVibration()
        }
        
        func removeFromHabit(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
            withAnimation(.easeInOut) {
                
                let habitObject = context.object(with: habit.objectID) as! HabitItem
                
                habitObject.addToHabit(-habitObject.wrappedStandardAddValue, date: shownDate, context: context)
                
                self.objectWillChange.send()
                
                habit.objectWillChange.send()
                
//                listViewModel.objectWillChange.send()
            }
            
            selectionChangedVibration()
        }
        
        func addRemoveMultiple(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext, fieldAnmation: Animation = .easeInOut) {
            let habitObject = context.object(with: habit.objectID) as! HabitItem
            
            withAnimation(.easeInOut) {
                if let number = NumberFormatter.habitValueNumberFormatter.number(from: multipleAddField) {
                    let toAdd: Double = number.doubleValue
                    
                    let rawAmountToDo = HabitValueTypes.rawAmountToDo(for: toAdd, valueType: habit.valueTypeEnum)
                    guard rawAmountToDo <= Double(Int64.max) && rawAmountToDo >= Double(Int64.min) + 1 else { return }
                    
//                    switch habit.valueTypeEnum {
//                    case .volumeLitres:
//                        toAdd = Int32(number.doubleValue * 1000)
//                    default:
//                        toAdd = number.int32Value
//                    }
                    
                    switch multipleAddSelection {
                    case .add:
                        habitObject.addToHabitForValueType(toAdd, valueType: selectedHabitTypeForMultipleAdd, date: shownDate, context: context)
                    case .remove:
                        habitObject.addToHabitForValueType(-toAdd, valueType: selectedHabitTypeForMultipleAdd, date: shownDate, context: context)
                    }
                } else {
                    errorVibration()
                }
                
                self.objectWillChange.send()
                
                habit.objectWillChange.send()
            }
            
            withAnimation(fieldAnmation) {
                self.multipleAddField = ""
                self.multipleAddShown = false
            }
            
            selectionChangedVibration()
        }
    }
    
}

