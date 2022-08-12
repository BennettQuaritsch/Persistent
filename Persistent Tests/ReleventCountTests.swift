//
//  ReleventCountTests.swift
//  Persistent Tests
//
//  Created by Bennett Quaritsch on 20.01.22.
//

import XCTest
@testable import Persistent
import CoreData

class ReleventCountTests: XCTestCase {
    
    let persistence = PersistenceController().container
    
    var habit: HabitItem!

    override func setUpWithError() throws {
        let context = persistence.viewContext
        
        habit = HabitItem(context: context)
        
        habit.id = UUID()
        habit.habitName = "Test"
        habit.amountToDo = 3
        
        habit.habitArchived = false
        
        habit.resetIntervalEnum = .daily
        
        habit.breakHabit = false
        
        habit.iconName = "tennis"
        
        habit.wrappedIconColorName = "Primary"
        
        var date = Date()
        
        for _ in 0...100000 {
            let dateItem = HabitCompletionDate(context: context)
            dateItem.date = date
            dateItem.habitValue = 2
            dateItem.item = habit
            
            date = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        }
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
}
