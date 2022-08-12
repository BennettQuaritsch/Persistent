//
//  AppIntent.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 27.07.22.
//

import Foundation
import AppIntents
import CoreData
import UIKit

struct OpenHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Open Habit"
    static var description = IntentDescription("Opens a habit you specify.")
    
    @Parameter(title: "Habit") var habit: HabitIntentEntity?
    
    @MainActor func perform() async throws -> some IntentResult {
        guard let habit else { throw $habit.requestValue("What habit do you want to open?") }
        
        await UIApplication.shared.open(URL(string: "persistent://openHabit/\(habit.id.uuidString)")!)
        
        return .result()
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Open \(\.$habit)")
    }
    
    static var openAppWhenRun: Bool = true
}

enum AppIntentError: Error {
    case outOfBounds
}

struct AddToHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Add to Habit"
    static var description = IntentDescription("Adds a value you specify to a habit you specify")
    
    @Parameter(title: "Habit") var habit: HabitIntentEntity?
    @Parameter(title: "Amount", controlStyle: .field, requestValueDialog: "Test?") var value: Double?
    
    @MainActor func perform() async throws -> some IntentResult {
        guard let habit else { throw $habit.requestValue("What habit do you want to add to?") }
        
        guard let value else { throw $value.requestValue("How much do you want to add?") }
        
        let habits = loadHabits()
        
        if let chosenHabit = habits.first(where: { $0.id == habit.id }) {
            chosenHabit.addToHabitForValueType(value, context: PersistenceController.shared.container.viewContext)
        }
        
        return .result(dialog: "Okay, added \(value) to \(habit).")
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("Add \(\.$value) to \(\.$habit)")
    }
}

struct HabitIntentEntity: AppEntity, Identifiable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = .init(name: "Habit")
    
    var id: UUID
    var habitName: String
    
    static var typeDisplayName: LocalizedStringResource = "Habit Name"
    
    static var defaultQuery = HabitQuery()
        
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(habitName)")
    }
    
    static var openAppWhenRun = true
}

struct HabitQuery: EntityStringQuery {
    func entities(for identifiers: [UUID]) async throws -> [HabitIntentEntity] {
        let habits = await loadHabits()
        let filteredHabits = habits.filter { identifiers.contains($0.id) }
        return filteredHabits.map {
            HabitIntentEntity(id: $0.id, habitName: $0.habitName)
        }
    }
    
    func suggestedEntities() async throws -> [HabitIntentEntity] {
        let habits = await loadHabits()
        return habits.map {
            HabitIntentEntity(id: $0.id, habitName: $0.habitName)
        }
    }
    
    func entities(matching string: String) async throws -> [HabitIntentEntity] {
        let habits = await loadHabits()
        let filteredHabits = habits.filter { $0.habitName.localizedCaseInsensitiveContains(string) }
        return filteredHabits.map {
            HabitIntentEntity(id: $0.id, habitName: $0.habitName)
        }
    }
}

@MainActor func loadHabits() -> [HabitItem] {
    let moc = PersistenceController.shared.container.viewContext
    let request: NSFetchRequest<HabitItem> = HabitItem.fetchRequest()
    request.propertiesToFetch = [NSString(string: "id"), NSString(string: "habitName")]
    
    do {
        let habits = try moc.fetch(request)
        return habits
    } catch {
        return []
    }
}

struct PersistentShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: OpenHabitIntent(), phrases: [
            "Open \(.applicationName) Habit",
            "Watch \(.applicationName) Habit",
            "See \(.applicationName) Habit"
        ], systemImageName: "arrow.up.forward.app.fill")
        
        AppShortcut(intent: AddToHabitIntent(), phrases: [
            "Add to \(.applicationName) Habit",
            "Add Value to \(.applicationName) Habit",
            "Append to \(.applicationName) Habit",
            "Add to \(.applicationName) Goal",
            "Add Value to \(.applicationName) Goal",
            "Append to \(.applicationName) Gaol"
        ], systemImageName: "plus")
    }
}
