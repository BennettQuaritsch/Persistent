//
//  AddToHabitIntentView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 05.09.22.
//

import SwiftUI

struct AddToHabitIntentView: View {
    let habit: HabitItem
    
    var body: some View {
        ZStack {
            ProgressBar(strokeWidth: 12, color: habit.iconColor, habit: habit)
                .frame(width: 150, height: 150)
            
            Text(verbatim: habit.relevantCountText(Date().adjustedForNightOwl()))
                .font(.system(.title, design: .rounded, weight: .black))
        }
        .padding(.top, 20)
        .padding(.bottom, 6)
    }
}

struct AddToHabitIntentView_Previews: PreviewProvider {
    static var previews: some View {
        AddToHabitIntentView(habit: HabitItem.testHabit)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
