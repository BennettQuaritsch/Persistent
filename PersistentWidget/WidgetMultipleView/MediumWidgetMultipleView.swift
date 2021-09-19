//
//  MediumWidgetMultipleView.swift
//  PersistentWidgetExtension
//
//  Created by Bennett Quaritsch on 26.08.21.
//

import SwiftUI

struct MediumWidgetMultipleView: View {
    init(chosenHabits: [HabitItem]) {
        self.habits = chosenHabits
    }
    
    let grids = [
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18),
        GridItem(.flexible(), spacing: 18)
    ]
    
    var habits: [HabitItem]
    
    var body: some View {
        VStack {
            LazyVGrid(columns: grids) {
                ForEach(habits, id: \.id) { habit in
                    ZStack {
                        NewProgressBar(strokeWidth: 5, progress: habit.progress(), color: habit.iconColor)
                            .aspectRatio(contentMode: .fit)
    
                        if habit.iconName != nil {
                            Image(habit.iconName!)
                                .resizable()
                                .foregroundColor(habit.iconColor)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 35)
                        }
                    }
                    .padding(3)
                }
            }
            .padding(10)
        }
    }
}

struct MediumWidgetMultipleView_Previews: PreviewProvider {
    static var previews: some View {
        MediumWidgetMultipleView(chosenHabits: [])
    }
}
