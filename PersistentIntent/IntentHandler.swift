//
//  IntentHandler.swift
//  PersistentIntent
//
//  Created by Bennett Quaritsch on 17.08.21.
//

import Intents
import CoreData

class IntentHandler: INExtension, SelectHabitIntentHandling, SelectMultipleHabitsIntentHandling {
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
        
        var collection: INObjectCollection<ChosenHabit>
        
        if let result = result {
            let filteredResults = result.filter { !$0.habitDeleted }
            
            let mappedResults: [ChosenHabit] = filteredResults.map {
                let chosenHabit = ChosenHabit(identifier: $0.id.uuidString, display: $0.habitName)
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
    
    
    func provideHabitOptionsCollection(for intent: SelectHabitIntent, with completion: @escaping (INObjectCollection<ChosenHabit>?, Error?) -> Void) {
        let test = ChosenHabit(identifier: "Test", display: "Test")
        test.name = "Test"
        
        let test2 = ChosenHabit(identifier: "Test2", display: "Test2")
        test2.name = "Test2"
        
        let request = NSFetchRequest<HabitItem>(entityName: "HabitItem")
        
        let result: [HabitItem]? = try? PersistenceController.shared.container.viewContext.fetch(request)
        
        var collection: INObjectCollection<ChosenHabit>
        
        if let result = result {
            let filteredResults = result.filter { !$0.habitDeleted }
            
            let mappedResults: [ChosenHabit] = filteredResults.map {
                let chosenHabit = ChosenHabit(identifier: $0.id.uuidString, display: $0.habitName)
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
