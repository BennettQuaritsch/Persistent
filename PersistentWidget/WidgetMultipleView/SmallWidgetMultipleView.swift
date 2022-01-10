//
//  SmallWidgetMultipleView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 18.08.21.
//

import SwiftUI
import CoreData

struct SmallWidgetMultipleView: View {
    @Environment(\.redactionReasons) var redactionReasons
    
    init(chosenHabits: [HabitItem]) {
        self.habits = chosenHabits
    }
    
    let grids = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var habits: [HabitItem]
    
    var body: some View {
        if redactionReasons == .placeholder {
            LazyVGrid(columns: grids) {
                ForEach(habits, id: \.id) { habit in
                    ZStack {
                        ProgressBar(strokeWidth: 7, progress: 0, color: .black)
                            .aspectRatio(contentMode: .fit)
                            .background(Circle().stroke(habit.iconColor.opacity(0.2), lineWidth: 7))
                        
                        Circle()
                            .foregroundColor(Color("systemGray6"))
                            .scaledToFit()
                    }
                    .padding(4)
                }
            }
            .padding(10)
        } else {
            if !habits.isEmpty {
                LazyVGrid(columns: grids) {
                    ForEach(habits, id: \.id) { habit in
                        ZStack {
                            ProgressBar(strokeWidth: 7, progress: habit.progress(), color: habit.iconColor)
                                .background(Circle().stroke(habit.iconColor.opacity(0.2), lineWidth: 7))
                            
                            if habit.iconName != nil {
                                Image(habit.iconName!)
                                    .resizable()
                                    .foregroundColor(habit.iconColor)
                                    .aspectRatio(contentMode: .fit)
                                    //.frame(height: 45)
                                    .padding(10)
                            }
                        }
                        .padding(4)
                    }
                }
                .padding(10)
            } else {
                Text("Configure your habits through long-pressing")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct SmallWidgetMultipleView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = PersistenceController().container.viewContext
        
        let habit = HabitItem(context: moc)
        habit.id = UUID()
        habit.habitName = "PreviewTest"
        habit.iconName = iconSections.randomElement()!.iconArray.randomElement()!
        habit.resetIntervalEnum = .daily
        habit.amountToDo = 4
        habit.iconColorIndex = Int16(iconColors.firstIndex(of: iconColors.randomElement()!)!)
        
        for _ in 1...Int.random(in: 1...6) {
            let date = HabitCompletionDate(context: moc)
            date.date = Date()
            date.item = habit
        }
        
        return SmallWidgetMultipleView(chosenHabits: [habit])
    }
}
