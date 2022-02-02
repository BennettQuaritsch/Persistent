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
    
    let grids = [
        GridItem(.flexible(), spacing: 17),
        GridItem(.flexible(), spacing: 17),
        GridItem(.flexible(), spacing: 17),
        GridItem(.flexible(), spacing: 17)
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
                            ProgressBar(strokeWidth: 7, color: habit.iconColor, habit: habit)
                                .background(Circle().stroke(habit.iconColor.opacity(0.2), lineWidth: 7))
                            
                            if habit.iconName != nil {
                                Image(habit.iconName!)
                                    .resizable()
                                    .foregroundColor(habit.iconColor)
                                    .aspectRatio(contentMode: .fit)
                                    .padding(10)
                                    //.frame(height: 35)
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

struct MediumWidgetMultipleView_Previews: PreviewProvider {
    static var previews: some View {
        MediumWidgetMultipleView(chosenHabits: [])
    }
}
