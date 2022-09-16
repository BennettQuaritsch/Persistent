//
//  SingleHabitWidgets.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 30.08.22.
//

import Foundation
import WidgetKit
import SwiftUI

struct HabitWidgetProvider: IntentTimelineProvider {
    func getItems() -> [HabitItem] {
        let moc = PersistenceController.shared.container.viewContext
        
        let request = HabitItem.fetchRequest()
        let result = try? moc.fetch(request)
        
        if let result = result {
            return result
        }
        return []
    }
    
    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(
            date: Date(),
            habit: HabitItem.testHabit,
            configuration: SelectHabitIntent()
        )
    }

    func getSnapshot(for configuration: SelectHabitIntent, in context: Context, completion: @escaping (HabitEntry) -> ()) {
        let items = getItems()
        
        guard let chosenItem = items.first(where: { $0.id.uuidString == configuration.habit?.identifier }) else { return }
        
        let entry = HabitEntry(
            date: Date(),
            habit: chosenItem,
            configuration: SelectHabitIntent()
        )
        
        completion(entry)
    }

    func getTimeline(for configuration: SelectHabitIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [HabitEntry] = []
        let items = getItems()
        
        guard let chosenItem = items.first(where: { $0.id.uuidString == configuration.habit?.identifier }) else { return }
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.defaultCalendar.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            
            let entry = HabitEntry(
                date: entryDate,
                habit: chosenItem,
                configuration: SelectHabitIntent()
            )
            
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct HabitEntry: TimelineEntry {
    let date: Date
    let habit: HabitItem
    let configuration: SelectHabitIntent
}

// Single Habit Widget für Homescreen
struct SingleHabitWidget: Widget {
    let kind: String = "SmallHabitProgressWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectHabitIntent.self, provider: HabitWidgetProvider()) { entry in
            SingleWidgetView(habit: entry.habit)
        }
        .configurationDisplayName("Widget.SingleHabit.Name")
        .description("Widget.SingleHabit.Description")
        .supportedFamilies([.systemSmall])
    }
}

// Single Habit Widget für Lockscreen / Apple Watch
struct CircularAccessoryWidget: Widget {
    let kind: String = "CircularAccessoryProgressWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectHabitIntent.self, provider: HabitWidgetProvider()) { entry in
            CircularAccessoryWidgetView(habit: entry.habit)
        }
        .configurationDisplayName("Widget.SingleHabit.Circular.Name")
        .description("Widget.SingleHabit.Circular.Description")
        .supportedFamilies([.accessoryCircular])
    }
}
