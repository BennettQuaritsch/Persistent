//
//  IntentHandler.swift
//  PersistentIntent
//
//  Created by Bennett Quaritsch on 17.08.21.
//

import Intents
import CoreData

class IntentHandler: INExtension, SelectHabitIntentHandling, SelectMultipleHabitsIntentHandling {
    func defaultHabits(for intent: SelectMultipleHabitsIntent) -> [ChosenHabit]? {
        let request = NSFetchRequest<HabitItem>(entityName: "HabitItem")
        
        let result: [HabitItem]? = try? PersistenceController.shared.container.viewContext.fetch(request)
        
        if let filteredResult = result?.filter({ !$0.habitArchived }) {
            let prefix = filteredResult.shuffled().prefix(4)
            
            let mappedResult: [ChosenHabit] = prefix.map {
                let chosenHabit = ChosenHabit(identifier: $0.id.uuidString, display: $0.habitName)
                chosenHabit.name = $0.habitName
                
                return chosenHabit
            }
            
            return mappedResult
        }
        
        return nil
    }
    
    ///Function for passig multiple Habits
    func provideHabitsOptionsCollection(for intent: SelectMultipleHabitsIntent, with completion: @escaping (INObjectCollection<ChosenHabit>?, Error?) -> Void) {
        let test = ChosenHabit(identifier: "Test", display: "Test")
        test.name = "Test"
        
        let test2 = ChosenHabit(identifier: "Test2", display: "Test2")
        test2.name = "Test2"
        
        let request = NSFetchRequest<HabitItem>(entityName: "HabitItem")
//        let predicate = NSPredicate(format: "habitDeleted != YES")
//        
//        request.predicate = predicate
        
        let result: [HabitItem]? = try? PersistenceController.shared.container.viewContext.fetch(request)
        
        var section: INObjectSection<ChosenHabit>
        
        if let result = result {
            let filteredResults = result.filter { !$0.habitArchived }
            
            let mappedResults: [ChosenHabit] = filteredResults.map {
                let chosenHabit = ChosenHabit(identifier: $0.id.uuidString, display: $0.habitName, subtitle: nil, image: INImage(named: $0.iconName ?? ""))
                chosenHabit.name = $0.habitName
                return chosenHabit
            }
            
            section = INObjectSection(title: "Your habits", items: mappedResults)
        } else {
            section = INObjectSection(title: "Your habits", items: [])
        }
        
        let noneSection = INObjectSection(title: "", items: [ChosenHabit(identifier: "NONE", display: "None")])
        
        let collection = INObjectCollection(sections: [noneSection, section])
        
        completion(collection, nil)
    }
    
    func defaultHabit(for intent: SelectHabitIntent) -> ChosenHabit? {
        let request = NSFetchRequest<HabitItem>(entityName: "HabitItem")
        
        let result: [HabitItem]? = try? PersistenceController.shared.container.viewContext.fetch(request)
        
        if let habitItem: HabitItem = result?.filter({ !$0.habitArchived }).randomElement() {
            let chosenHabit = ChosenHabit(identifier: habitItem.id.uuidString, display: habitItem.habitName)
            chosenHabit.name = habitItem.habitName
            
            return chosenHabit
        }
        
        return nil
    }
    
    func provideHabitOptionsCollection(for intent: SelectHabitIntent, with completion: @escaping (INObjectCollection<ChosenHabit>?, Error?) -> Void) {
        let test = ChosenHabit(identifier: "Test", display: "Test")
        test.name = "Test"
        
        let test2 = ChosenHabit(identifier: "Test2", display: "Test2")
        test2.name = "Test2"
        
        let request = NSFetchRequest<HabitItem>(entityName: "HabitItem")
        
        let result: [HabitItem]? = try? PersistenceController.shared.container.viewContext.fetch(request)
        
        var collection: INObjectCollection<ChosenHabit>
        
        if let result = result {
            let filteredResults = result.filter { !$0.habitArchived }
            
            let mappedResults: [ChosenHabit] = filteredResults.map {
                let chosenHabit = ChosenHabit(identifier: $0.id.uuidString, display: $0.habitName, subtitle: nil, image: INImage(named: $0.iconName ?? ""))
                chosenHabit.name = $0.habitName
                return chosenHabit
            }
            
            collection = INObjectCollection(items: mappedResults)
        } else {
            let habits: [ChosenHabit] = [test, test2]
            
            collection = INObjectCollection(items: habits)
        }
        
        completion(collection, nil)
    }
    
    
    
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
