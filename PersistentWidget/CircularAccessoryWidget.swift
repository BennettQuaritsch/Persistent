//
//  CircularAccessoryWidget.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 04.07.22.
//

import SwiftUI
import WidgetKit

struct CircularAccessoryWidgetView: View {
    let habit: HabitItem?
    
    var body: some View {
        if let habit = habit {
            ZStack {
                ProgressBar(strokeWidth: 6, color: habit.iconColor, habit: habit, date: Date().adjustedForNightOwl())
                    .padding(3)
                
                if habit.iconName != nil {
                    Image(habit.iconName!)
                        .resizable()
//                        .widgetAccentable()
                        .foregroundColor(habit.iconColor)
                        .aspectRatio(contentMode: .fit)
                        .padding(10)
                }
            }
        }
    }
}



struct CircularAccessoryWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        CircularAccessoryWidgetView(habit: HabitItem.testHabit)
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
