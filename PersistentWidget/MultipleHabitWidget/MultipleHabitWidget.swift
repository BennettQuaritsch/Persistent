//
//  MultipleHabitWidget.swift
//  PersistentWidgetExtension
//
//  Created by Bennett Quaritsch on 30.08.22.
//

import Foundation
import WidgetKit
import SwiftUI

struct MultipleHabitsWidgetProvider: IntentTimelineProvider {
    func getItems() -> [HabitItem] {
        let moc = PersistenceController.shared.container.viewContext
        
        let request = HabitItem.fetchRequest()
        let result = try? moc.fetch(request)
        
        if let result = result {
            return result
        }
        return []
    }
    
    func placeholder(in context: Context) -> MultipleHabitsEntry {
        MultipleHabitsEntry(date: Date(), habits: Array.init(repeating: HabitItem.testHabit, count: 8), configuration: SelectMultipleHabitsIntent())
    }

    func getSnapshot(for configuration: SelectMultipleHabitsIntent, in context: Context, completion: @escaping (MultipleHabitsEntry) -> ()) {
        let items = getItems()
        let filteredItems = configuration.habits?.compactMap { chosenHabit in
            return items.first(where: { $0.id.uuidString == chosenHabit.identifier })
        }
        
        let entry = MultipleHabitsEntry(date: Date(), habits: filteredItems ?? Array.init(repeating: HabitItem.testHabit, count: 8), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: SelectMultipleHabitsIntent, in context: Context, completion: @escaping (Timeline<MultipleHabitsEntry>) -> ()) {
        var entries: [MultipleHabitsEntry] = []
        let items = getItems()
        let filteredItems = configuration.habits?.compactMap { chosenHabit in
            return items.first(where: { $0.id.uuidString == chosenHabit.identifier })
        }
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.defaultCalendar.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = MultipleHabitsEntry(date: entryDate, habits: filteredItems ?? [], configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct MultipleHabitsEntry: TimelineEntry {
    let date: Date
    let habits: [HabitItem]
    let configuration: SelectMultipleHabitsIntent
}

struct MultipleHabitsWidgetView: View {
    @Environment(\.widgetFamily) var family
    
    var habits: [HabitItem]
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetMultipleView(chosenHabits: habits)
        case .systemMedium:
            MediumWidgetMultipleView(chosenHabits: habits)
        default:
            SmallWidgetMultipleView(chosenHabits: habits)
        }
    }
}

struct MultipleHabitsWidget: Widget {
    let kind: String = "MultipleHabitsProgressWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectMultipleHabitsIntent.self, provider: MultipleHabitsWidgetProvider()) { entry in
            MultipleHabitsWidgetView(habits: entry.habits)
        }
        .configurationDisplayName("Widget.MultipleHabits.Name")
        .description("Widget.MultipleHabits.Description")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
