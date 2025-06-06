//
//  MediumWidgetMultipleView.swift
//  PersistentWidgetExtension
//
//  Created by Bennett Quaritsch on 26.08.21.
//

import SwiftUI

struct MediumWidgetMultipleView: View {
    @Environment(\.redactionReasons) var redactionReasons
    
    init(chosenHabits: [HabitItem]) {
        self.habits = chosenHabits
    }
    
    var dividerInt: Int {
        if habits.count <= 6 && habits.count > 4 {
            return 3
        } else if habits.count > 6 {
            return 4
        }
        return 1
    }
    
    var spacing: CGFloat {
        if habits.count <= 6 && habits.count > 4 {
            return 30
        }
        return 17
    }
    
    var grids: [GridItem] {
        if habits.count <= 4 {
            return Array.init(repeating: GridItem(.flexible()), count: habits.count)
        } else if habits.count <= 6 {
            return Array.init(repeating: GridItem(.fixed(70), spacing: 30), count: 3)
        }
        return Array.init(repeating: GridItem(.flexible()), count: 4)
    }
    
    
    var habits: [HabitItem]
    
    var body: some View {
        if !habits.isEmpty {
            VStack(spacing: 0) {
                LazyVGrid(columns: grids, alignment: .center) {
                    ForEach(habits.dropLast(habits.count % dividerInt), id: \.id) { habit in
                        Link(destination: URL(string: "persistent://openHabit/\(habit.id.uuidString)")!) {
                            ZStack {
                                ProgressBar(strokeWidth: 6, color: habit.iconColor, habit: habit, date: Date().adjustedForNightOwl())
                                    .background(Circle().stroke(habit.iconColor.opacity(0.2), lineWidth: 7))
                                
                                if habit.iconName != nil {
                                    Image(habit.iconName!)
                                        .resizable()
                                        .foregroundColor(habit.iconColor)
                                        .aspectRatio(contentMode: .fit)
                                        .padding(12)
                                        //.frame(height: 35)
                                }
                            }
                        }
                        .frame(width: 52, height: 52)
                        .padding(3)
                    }
                }
                
                if habits.count > 4 {
                    LazyHStack(spacing: spacing) {
                        ForEach(habits.suffix(habits.count % dividerInt), id: \.id) { habit in
                            ZStack {
                                ProgressBar(strokeWidth: 6, color: habit.iconColor, habit: habit, date: Date().adjustedForNightOwl())
                                    .background(Circle().stroke(habit.iconColor.opacity(0.2), lineWidth: 7))
                                
                                if habit.iconName != nil {
                                    Image(habit.iconName!)
                                        .resizable()
                                        .foregroundColor(habit.iconColor)
                                        .aspectRatio(contentMode: .fit)
                                        .padding(12)
                                        //.frame(height: 35)
                                }
                            }
                            .frame(width: 52, height: 52)
                            .padding(3)
                            
                        }
                    }
                }
            }
            .padding(13)
        } else {
            Text("Configure your habits through long-pressing")
                .font(.headline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        }
    }
}

struct MediumWidgetMultipleView_Previews: PreviewProvider {
    static var previews: some View {
        MediumWidgetMultipleView(chosenHabits: [])
    }
}
