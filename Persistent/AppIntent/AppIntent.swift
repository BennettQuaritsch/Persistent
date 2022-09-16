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
    static var title: LocalizedStringResource = "AppIntents.OpenHabitIntent.Title"
    static var description = IntentDescription("AppIntents.OpenHabitIntent.Description")
    
    @Parameter(title: "AppIntents.Parameter.Habit") var habit: HabitIntentEntity?
    
    @MainActor func perform() async throws -> some IntentResult {
        guard let habit else { throw $habit.needsValueError("AppIntents.OpenHabitIntent.Parameter.Habit.ValueRequest") }
        
        let _ = await UIApplication.shared.open(URL(string: "persistent://openHabit/\(habit.id.uuidString)")!)
        
        return .result()
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("AppIntents.OpenHabitIntent.Summary \(\.$habit)")
    }
    
    static var openAppWhenRun: Bool = true
}

enum AppIntentError: Error {
    case outOfBounds, habitNotFound
}

struct AddToHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "AppIntents.AddToHabitIntent.Title"
    static var description = IntentDescription("AppIntents.AddToHabitIntent.Description")
    
    @Parameter(title: "AppIntents.Parameter.Habit") var habit: HabitIntentEntity?
    @Parameter(title: "AppIntents.Parameter.Amount", controlStyle: .field) var value: Double?
    
    @MainActor func perform() async throws -> some IntentResult {
        guard let habit else { throw $habit.needsValueError("AppIntents.AddToHabitIntent.Parameter.Habit.ValueRequest") }
        
        guard let value else { throw $value.needsValueError("AppIntents.AddToHabitIntent.Parameter.Amount.ValueRequest") }
        
        let habits = loadHabits()
        
        guard let chosenHabit = habits.first(where: { $0.id == habit.id }) else { throw AppIntentError.habitNotFound }
        
        chosenHabit.addToHabitForValueType(value, date: Date().adjustedForNightOwl(), context: PersistenceController.shared.container.viewContext)
        
        var dialog: IntentDialog
        
        if habit.valueType != .number {
            dialog = IntentDialog(LocalizedStringResource("AppIntents.AddToHabitIntent.Result.Dialog.ValueType %1$@ %2$@ %3$@", defaultValue: "AppIntents.AddToHabitIntent.Result.Dialog.ValueType \(value.formatted(.number)) \(NSLocalizedString(habit.valueType.localizedNameString, comment: "")) \(habit.habitName)"))
        } else {
            dialog = IntentDialog(LocalizedStringResource("AppIntents.AddToHabitIntent.Result.Dialog %1$@ %2$@", defaultValue: "AppIntents.AddToHabitIntent.Result.Dialog \(value.formatted(.number)) \(habit.habitName)"))
        }
        
        return .result(
            dialog: dialog,
            view: AddToHabitIntentView(habit: chosenHabit)
        )
        
        
    }
    
    static var parameterSummary: some ParameterSummary {
        Summary("AppIntents.AddToHabitIntent.Summary \(\.$value) \(\.$habit)")
    }
}

//struct GetHabitValueIntent: AppIntent {
//    static var title: LocalizedStringResource = "Get Habit Progress"
//    static var description = IntentDescription("Get the progress amount of the habit you specify.")
//
//    @Parameter(title: "Habit") var habit: HabitIntentEntity?
//    @Parameter(title: "Date") var date: Date
//
//    @MainActor func perform() async throws -> some IntentResult {
//        guard let habit else { throw $habit.needsValueError("What habit do you want to add to?") }
//
////        guard let date else { throw $date.needsValueError("How much do you want to add?") }
//
//        let habits = loadHabits()
//
//        if let chosenHabit = habits.first(where: { $0.id == habit.id }) {
////            chosenHabit.addToHabitForValueType(value, context: PersistenceController.shared.container.viewContext)
//        }
//
//        if habit.valueType != .number {
//            return .result(dialog: "Okay \(NSLocalizedString(habit.valueType.localizedNameString, comment: "")) to \(habit.habitName).")
//        }
//
//        return .result(dialog: "Okay, added to \(habit.habitName).")
//    }
//
//    static var parameterSummary: some ParameterSummary {
//        Summary("Get \(\.$habit) progress of \(\.$date)")
//    }
//}

// Entity

struct HabitIntentEntity: AppEntity, Identifiable {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "AppIntents.Entities.Habit.TypeDisplayRepresentation"
    
    var id: UUID
    var habitName: String
    var valueType: HabitValueTypes
    var imageName: String
    
    static var typeDisplayName: LocalizedStringResource = "AppIntents.Entities.Habit.TypeDisplayName"
    
    static var defaultQuery = HabitQuery()
        
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: LocalizedStringResource(stringLiteral: habitName), image: .init(named: imageName))
    }
    
    static var openAppWhenRun = true
}

struct HabitQuery: EntityStringQuery {
    func entities(for identifiers: [UUID]) async throws -> [HabitIntentEntity] {
        let habits = await loadHabits()
        let filteredHabits = habits.filter { identifiers.contains($0.id) }
        return filteredHabits.map {
            HabitIntentEntity(id: $0.id, habitName: $0.habitName, valueType: $0.valueTypeEnum, imageName: $0.wrappedIconName)
        }
    }
    
    func suggestedEntities() async throws -> [HabitIntentEntity] {
        let habits = await loadHabits()
        return habits.map {
            HabitIntentEntity(id: $0.id, habitName: $0.habitName, valueType: $0.valueTypeEnum, imageName: $0.wrappedIconName)
        }
    }
    
    func entities(matching string: String) async throws -> [HabitIntentEntity] {
        let habits = await loadHabits()
        let filteredHabits = habits.filter { $0.habitName.localizedCaseInsensitiveContains(string) }
        return filteredHabits.map {
            HabitIntentEntity(id: $0.id, habitName: $0.habitName, valueType: $0.valueTypeEnum, imageName: $0.wrappedIconName)
        }
    }
}

@MainActor func loadHabits() -> [HabitItem] {
    let moc = PersistenceController.shared.container.viewContext
    let request: NSFetchRequest<HabitItem> = HabitItem.fetchRequest()
    request.propertiesToFetch = [NSString(string: "id"), NSString(string: "habitName"), NSString(string: "valueType"), NSString(string: "iconName")]
    
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
            "See \(.applicationName) Habit",
            "Open \(.applicationName) \(\.$habit)",
            "Open \(\.$habit) at \(.applicationName)",
            "Open \(\.$habit) in \(.applicationName)",
        ], systemImageName: "arrow.up.forward.app.fill")
        
        
        AppShortcut(intent: AddToHabitIntent(), phrases: [
            "Add to \(.applicationName) Habit",
            "Add Value to \(.applicationName) Habit",
            "Add Amount to \(.applicationName) Habit",
            "Add to \(.applicationName) Goal",
            "Add Value to \(.applicationName) Goal",
            "Add Amount to \(.applicationName) Goal",
            "Add to \(.applicationName) \(\.$habit)",
            "Add Value to \(.applicationName) \(\.$habit)",
            "Add Amount to \(.applicationName) \(\.$habit)",
            "Add to \(\.$habit) at \(.applicationName)",
            "Add to \(\.$habit) in \(.applicationName)",
            "Add to \(\.$habit) from \(.applicationName)",
        ], systemImageName: "plus")
    }
}
