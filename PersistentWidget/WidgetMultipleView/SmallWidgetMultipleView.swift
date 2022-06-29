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
        if chosenHabits.count > 4 {
            var habits = chosenHabits
            habits.removeLast(chosenHabits.count - 4)
            self.habits = habits
        } else {
            self.habits = chosenHabits
        }
        
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
                            ProgressBar(strokeWidth: 7, color: habit.iconColor, habit: habit, date: Date().adjustedForNightOwl())
                                .background(Circle().stroke(habit.iconColor.opacity(0.2), lineWidth: 7))
                            
                            if habit.iconName != nil {
                                Image(habit.iconName!)
                                    .resizable()
                                    .foregroundColor(habit.iconColor)
                                    .aspectRatio(contentMode: .fit)
                                    //.frame(height: 45)
                                    .padding(12)
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
        return SmallWidgetMultipleView(chosenHabits: [HabitItem.testHabit])
    }
}
