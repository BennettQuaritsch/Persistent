//
//  IntentHandler.swift
//  PersistentIntent
//
//  Created by Bennett Quaritsch on 17.08.21.
//

import Intents
import CoreData

class IntentHandler: INExtension, SelectHabitIntentHandling, SelectMultipleHabitsIntentHandling, SelectHabitForBarChartIntentHandling {
    // SelectMultipleHabits Intent
    func defaultHabits(for intent: SelectMultipleHabitsIntent) -> [ChosenHabit]? {
        let request = HabitItem.fetchRequest()
        
        let result: [HabitItem]? = try? PersistenceController.shared.container.viewContext.fetch(request)
        
        if let filteredResult = result?.filter({ !$0.habitArchived }) {
            let prefix = filteredResult.shuffled().prefix(4)
            
            let mappedResult: [ChosenHabit] = prefix.map {
                let chosenHabit = ChosenHabit(identifier: $0.id.uuidString, display: $0.habitName, subtitle: nil, image: INImage(named: $0.wrappedIconName))
                chosenHabit.name = $0.habitName
                
                return chosenHabit
            }
            
            return mappedResult
        }
        
        return nil
    }
    
    func provideHabitsOptionsCollection(for intent: SelectMultipleHabitsIntent, with completion: @escaping (INObjectCollection<ChosenHabit>?, Error?) -> Void) {
        let request = HabitItem.fetchRequest()
        
        let result: [HabitItem]? = try? PersistenceController.shared.container.viewContext.fetch(request)
        
        var section: INObjectSection<ChosenHabit>
        
        if let result = result {
            let filteredResults = result.filter { !$0.habitArchived }
            
            let mappedResults: [ChosenHabit] = filteredResults.map {
                let chosenHabit = ChosenHabit(identifier: $0.id.uuidString, display: $0.habitName, subtitle: nil, image: INImage(named: $0.wrappedIconName))
                chosenHabit.name = $0.habitName
                return chosenHabit
            }
            
            section = INObjectSection(title: NSLocalizedString("IntentHandler.Sections.Habits.Title", comment: ""), items: mappedResults)
        } else {
            section = INObjectSection(title: NSLocalizedString("IntentHandler.Sections.Habits.Title", comment: ""), items: [])
        }
        
        let noneSection = INObjectSection(title: "", items: [ChosenHabit(identifier: "NONE", display: NSLocalizedString("IntentHandler.Sections.None.Body", comment: ""))])
        
        let collection = INObjectCollection(sections: [noneSection, section])
        
        completion(collection, nil)
    }
    
    // SelectHabit Intent
    func defaultHabit(for intent: SelectHabitIntent) -> ChosenHabit? {
        returnDefaultHabit()
    }
    
    func provideHabitOptionsCollection(for intent: SelectHabitIntent, with completion: @escaping (INObjectCollection<ChosenHabit>?, Error?) -> Void) {
        let habitOptions = returnSingleHabitOptions()
        
        let collection = INObjectCollection(items: habitOptions)
        
        completion(collection, nil)
    }
    
    // SelectHabitForBarChart Intent
    func defaultHabit(for intent: SelectHabitForBarChartIntent) -> ChosenHabit? {
        returnDefaultHabit()
    }
    
    func provideHabitOptionsCollection(for intent: SelectHabitForBarChartIntent) async throws -> INObjectCollection<ChosenHabit> {
        let habitOptions = returnSingleHabitOptions()
        
        let collection = INObjectCollection(items: habitOptions)
        
        return collection
    }
    
    func resolveBarChartSize(for intent: SelectHabitForBarChartIntent) async -> BarChartSizeEnumResolutionResult {
        return BarChartSizeEnumResolutionResult.needsValue()
    }
    
    // Funktionen als Basis für die IntentHandler Funktionen
    func returnDefaultHabit() -> ChosenHabit? {
        let request = HabitItem.fetchRequest()
        
        let result: [HabitItem]? = try? PersistenceController.shared.container.viewContext.fetch(request)
        
        guard let habitItem: HabitItem = result?.filter({ !$0.habitArchived }).randomElement() else { return nil }
        
        let chosenHabit = ChosenHabit(
            identifier: habitItem.id.uuidString,
            display: habitItem.habitName,
            subtitle: nil,
            image: INImage(named: habitItem.wrappedIconName)
        )
        
        chosenHabit.name = habitItem.habitName
        
        return chosenHabit
    }
    
    func returnSingleHabitOptions() -> [ChosenHabit] {
        let request = HabitItem.fetchRequest()
        
        let result: [HabitItem]? = try? PersistenceController.shared.container.viewContext.fetch(request)
        
        guard let result else { return [] }
        
        let filteredResults = result.filter { !$0.habitArchived }
        
        let mappedResults: [ChosenHabit] = filteredResults.map { habit in
            let chosenHabit = ChosenHabit(
                identifier: habit.id.uuidString,
                display: habit.habitName,
                subtitle: nil,
                image: INImage(named: habit.wrappedIconName)
            )
            
            chosenHabit.name = habit.habitName
            
            return chosenHabit
        }
        
        return mappedResults
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
