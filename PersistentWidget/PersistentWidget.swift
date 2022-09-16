//
//  PersistentWidget.swift
//  PersistentWidget
//
//  Created by Bennett Quaritsch on 27.07.21.
//

import WidgetKit
import SwiftUI
import CoreData

@main
struct PersistentWidgetBundle: WidgetBundle {
    var body: some Widget {
        SingleHabitWidget()
        MultipleHabitsWidget()
        CircularAccessoryWidget()
        RoundedBarChartWidget()
    }
}

struct PersistentWidget_Previews: PreviewProvider {
    static var previews: some View {
        SingleWidgetView(habit: HabitItem.testHabit)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
        
        
        CircularAccessoryWidgetView(habit: HabitItem.testHabit)
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
            .previewDisplayName("Test")
    }
}
