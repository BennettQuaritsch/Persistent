//
//  SmallWidgetMultipleView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 18.08.21.
//

import SwiftUI
import CoreData

var testHabit: HabitItem {
    let testItem: HabitItem = HabitItem(context: PersistenceController.shared.container.viewContext)
    testItem.habitName = "Test"
    testItem.amountToDo = Int16(3)
    testItem.resetIntervalEnum = .daily
    testItem.id = UUID()
    testItem.iconColorIndex = Int16(1)
    testItem.iconName = "Walking"
    
    return testItem
}

var testHabit2: HabitItem {
    let testItem: HabitItem = HabitItem(context: PersistenceController.shared.container.viewContext)
    testItem.habitName = "Test"
    testItem.amountToDo = Int16(3)
    testItem.resetIntervalEnum = .daily
    testItem.id = UUID()
    testItem.iconColorIndex = Int16(1)
    testItem.iconName = "Walking"
    
    return testItem
}

var testHabit3: HabitItem {
    let testItem: HabitItem = HabitItem(context: PersistenceController.shared.container.viewContext)
    testItem.habitName = "Test"
    testItem.amountToDo = Int16(3)
    testItem.resetIntervalEnum = .daily
    testItem.id = UUID()
    testItem.iconColorIndex = Int16(1)
    testItem.iconName = "Walking"
    
    return testItem
}

var testHabit4: HabitItem {
    let testItem: HabitItem = HabitItem(context: PersistenceController.shared.container.viewContext)
    testItem.habitName = "Test"
    testItem.amountToDo = Int16(3)
    testItem.resetIntervalEnum = .daily
    testItem.id = UUID()
    testItem.iconColorIndex = Int16(1)
    testItem.iconName = "Walking"
    
    return testItem
}

struct SmallWidgetMultipleView: View {
    init(chosenHabits: [HabitItem]) {
        self.habits = chosenHabits
    }
    
    let testHabits = [testHabit, testHabit2, testHabit3, testHabit4]
    
    let grids = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var habits: [HabitItem]
    
    var body: some View {
        if !habits.isEmpty {
            LazyVGrid(columns: grids) {
                ForEach(habits, id: \.id) { habit in
                    ZStack {
                        NewProgressBar(strokeWidth: 5, progress: habit.progress(), color: habit.iconColor)
                            .aspectRatio(contentMode: .fit)
                        
                        if habit.iconName != nil {
                            ZStack {
                                Image(habit.iconName!)
                                    .resizable()
                                    .foregroundColor(habit.iconColor)
                                
                            }
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 35)
                        }
                    }
                    .padding(3)
                }
            }
            .padding(10)
        } else {
            Text("Choose a habit")
        }
    }
}

struct SmallWidgetMultipleView_Previews: PreviewProvider {
    static var previews: some View {
        SmallWidgetMultipleView(chosenHabits: [])
    }
}
