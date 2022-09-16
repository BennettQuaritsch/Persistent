//
//  CircularAccessoryWidget.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 04.07.22.
//

import SwiftUI
import WidgetKit

struct CircularAccessoryWidgetView: View {
    let habit: HabitItem
    
    var body: some View {
        ZStack {
            ProgressBar(strokeWidth: 6, color: .primary, habit: habit, date: Date().adjustedForNightOwl())
                .widgetAccentable()
                .background(Circle().stroke(habit.iconColor.opacity(0.2), lineWidth: 6))
                .padding(3)
            
            habit.wrappedIcon
                .resizable()
                .widgetAccentable()
//                .foregroundColor(habit.iconColor)
                .aspectRatio(contentMode: .fit)
                .padding(12)
        }
        .widgetURL(URL(string: "persistent://openHabit/\(habit.id.uuidString)"))
    }
}



struct CircularAccessoryWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        CircularAccessoryWidgetView(habit: HabitItem.testHabit)
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
