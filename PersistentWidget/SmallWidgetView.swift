//
//  SmallWidgetView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 27.07.21.
//

import SwiftUI
import CoreData
import WidgetKit

struct SmallWidgetView: View {
    var habit: HabitItem
    
    let iconColors: [Color] = [Color.primary, Color.red, Color.orange, Color.yellow, Color.green, Color.pink, Color.purple]
    
    let shownDate = Date()
    
    var body: some View {
        ZStack {
            NewProgressBar(strokeWidth: 10, progress: habit.progress(), color: habit.iconColor)
                .padding()
            
            if habit.iconName != nil {
                ZStack {
                    Image(habit.iconName!)
                        .resizable()
                        .foregroundColor(habit.iconColor)
                    
                }
                .aspectRatio(contentMode: .fit)
                .frame(height: 70)
            }
        }
        .onAppear {
            print(habit.iconName!)
        }
    }
}

struct SmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        var testHabit: HabitItem {
        
            let testItem: HabitItem = HabitItem(context: PersistenceController.shared.container.viewContext)
            testItem.habitName = "Test"
            testItem.amountToDo = Int16(3)
            testItem.resetIntervalEnum = .daily
            testItem.id = UUID()
            testItem.iconColorIndex = Int16(1)
            testItem.iconName = "Walking"
            
            let anotherNewItem = HabitCompletionDate(context: PersistenceController.shared.container.viewContext)
            anotherNewItem.date = Date()
            anotherNewItem.item = testItem
            
            let secondNewItem = HabitCompletionDate(context: PersistenceController.shared.container.viewContext)
            secondNewItem.date = Date()
            secondNewItem.item = testItem
            
            return testItem
        }
        return SmallWidgetView(habit: testHabit)
            .previewLayout(.sizeThatFits)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
