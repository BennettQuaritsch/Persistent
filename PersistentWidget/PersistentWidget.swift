//
//  PersistentWidget.swift
//  PersistentWidget
//
//  Created by Bennett Quaritsch on 27.07.21.
//

import WidgetKit
import SwiftUI
import Intents
import CoreData

struct Provider: IntentTimelineProvider {
    var previewTestHabit: HabitItem {
        let habit = HabitItem(context: PersistenceController.preview.container.viewContext)
        habit.id = UUID()
        habit.habitName = "PreviewTest"
        habit.iconName = iconChoices.randomElement()!
        habit.resetIntervalEnum = .daily
        habit.amountToDo = 4
        habit.iconColorIndex = Int16(iconColors.firstIndex(of: iconColors.randomElement()!)!)
        
        for _ in 1...Int.random(in: 1...6) {
            let date = HabitCompletionDate(context: PersistenceController.preview.container.viewContext)
            date.date = Date()
            date.item = habit
        }
        return habit
    }
    
    func getItems() -> [HabitItem] {
        let moc = PersistenceController.shared.container.viewContext
        
        let request = NSFetchRequest<HabitItem>(entityName: "HabitItem")
        let result = try? moc.fetch(request)
        
        if let result = result {
            return result
        }
        return []
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), habit: previewTestHabit, configuration: SelectHabitIntent())
    }

    func getSnapshot(for configuration: SelectHabitIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let items = getItems()
        let chosenItem = items.first(where: { $0.id.uuidString == configuration.habit?.identifier })
        
        let entry = SimpleEntry(date: Date(), habit: chosenItem, configuration: SelectHabitIntent())
        completion(entry)
    }

    func getTimeline(for configuration: SelectHabitIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let items = getItems()
        
        let chosenItem = items.first(where: { $0.id.uuidString == configuration.habit?.identifier })
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, habit: chosenItem, configuration: SelectHabitIntent())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct MultipleHabitsProvider: IntentTimelineProvider {
    var previewTestHabit: HabitItem {
        let habit = HabitItem(context: PersistenceController.preview.container.viewContext)
        habit.id = UUID()
        habit.habitName = "PreviewTest"
        habit.iconName = iconChoices.randomElement()!
        habit.resetIntervalEnum = .daily
        habit.amountToDo = 4
        habit.iconColorIndex = Int16(iconColors.firstIndex(of: iconColors.randomElement()!)!)
        
        for _ in 1...Int.random(in: 1...6) {
            let date = HabitCompletionDate(context: PersistenceController.preview.container.viewContext)
            date.date = Date()
            date.item = habit
        }
        
        return habit
    }
    func getItems() -> [HabitItem] {
        let moc = PersistenceController.shared.container.viewContext
        
        let request = NSFetchRequest<HabitItem>(entityName: "HabitItem")
        let result = try? moc.fetch(request)
        
        if let result = result {
            return result
        }
        return []
    }
    
    func placeholder(in context: Context) -> MultipleEntry {
        MultipleEntry(date: Date(), habits: Array.init(repeating: previewTestHabit, count: 4), configuration: SelectMultipleHabitsIntent())
    }

    func getSnapshot(for configuration: SelectMultipleHabitsIntent, in context: Context, completion: @escaping (MultipleEntry) -> ()) {
        let items = getItems()
        let filteredItems = configuration.habits?.compactMap { chosenHabit in
            return items.first(where: { $0.id.uuidString == chosenHabit.identifier })
        }
        
        let entry = MultipleEntry(date: Date(), habits: filteredItems ?? Array.init(repeating: previewTestHabit, count: 4), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: SelectMultipleHabitsIntent, in context: Context, completion: @escaping (Timeline<MultipleEntry>) -> ()) {
        var entries: [MultipleEntry] = []
        let items = getItems()
        let filteredItems = configuration.habits?.compactMap { chosenHabit in
            return items.first(where: { $0.id.uuidString == chosenHabit.identifier })
        }
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = MultipleEntry(date: entryDate, habits: filteredItems ?? [], configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct MultipleEntry: TimelineEntry {
    let date: Date
    let habits: [HabitItem]
    let configuration: SelectMultipleHabitsIntent
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let habit: HabitItem?
    let configuration: SelectHabitIntent
}

struct PersistentWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            SmallWidgetView(habit: entry.habit)
        }
    }
}

struct MultipleWidgetsEntryView: View {
    @Environment(\.widgetFamily) var family
    
    var entry: MultipleEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetMultipleView(chosenHabits: entry.habits)
        case .systemMedium:
            MediumWidgetMultipleView(chosenHabits: entry.habits)
        default:
            SmallWidgetMultipleView(chosenHabits: entry.habits)
        }
    }
}

struct PersistentWidget: Widget {
    let kind: String = "BigWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectHabitIntent.self, provider: Provider()) { entry in
            PersistentWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Big Habit")
        .description("This widget shows your habits in a big way!")
        .supportedFamilies([.systemSmall])
    }
}

struct MultipleHabitsWidget: Widget {
    let kind: String = "MultipleWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectMultipleHabitsIntent.self, provider: MultipleHabitsProvider()) { entry in
            MultipleWidgetsEntryView(entry: entry)
        }
        .configurationDisplayName("Multiple Habits Widget")
        .description("See multiple habits at once! Choose your habits through long pressing.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct MediumGraphWidget: Widget {
    let kind: String = "Medium sized Graph Widget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: SelectHabitIntent.self, provider: Provider()) { entry in
            MediumGraphWidgetView(habit: entry.habit)
        }
        .configurationDisplayName("Graph Widget")
        .description("See how you are doing! Choose your habit through long pressing.")
        .supportedFamilies([.systemMedium])
    }
}

@main
struct PersistentWidgetBundle: WidgetBundle {
    var body: some Widget {
        PersistentWidget()
        MultipleHabitsWidget()
        MediumGraphWidget()
    }
}

struct PersistentWidget_Previews: PreviewProvider {
    static var previews: some View {
        let habit = HabitItem(context: PersistenceController.preview.container.viewContext)
        habit.id = UUID()
        habit.habitName = "PreviewTest"
        habit.iconName = iconChoices.randomElement()!
        habit.resetIntervalEnum = .daily
        habit.amountToDo = 4
        habit.iconColorIndex = Int16(iconColors.firstIndex(of: iconColors.randomElement()!)!)
        
        for _ in 1...Int.random(in: 1...6) {
            let date = HabitCompletionDate(context: PersistenceController.preview.container.viewContext)
            date.date = Date()
            date.item = habit
        }
        
        return PersistentWidgetEntryView(entry: SimpleEntry(date: Date(), habit: habit, configuration: SelectHabitIntent()))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
