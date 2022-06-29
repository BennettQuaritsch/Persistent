//
//  Timer.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 11.04.22.
//

import Foundation
import Combine
import CoreData
import SwiftUI

class HabitTimer: ObservableObject {
    @Published private(set) var timerRunning: Bool = false
    
    private var timer: AnyCancellable?
    
    let habit: HabitItem
    var context: NSManagedObjectContext?
    
    init(habit: HabitItem) {
        self.habit = habit
    }
    
    func start() {
        timer = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if let context = self.context {
                    withAnimation {
                        self.habit.addToHabit(1, date: Date().adjustedForNightOwl(), context: context)
                        self.habit.objectWillChange.send()
                        self.objectWillChange.send()
                        
                        print("count from timer: \(self.habit.relevantCount().formatted())")
                    }
                }
            }
        
        self.timerRunning = true
    }
    
    func stop() {
        self.timer?.cancel()
        self.timer = nil
        self.timerRunning = false
        self.habit.timerStartDate = nil
    }
    
    func pause() {
        self.timer?.cancel()
        self.timer = nil
        self.timerRunning = false
    }
    
    func saveDate() {
        if timerRunning {
            print("save")
            self.habit.timerStartDate = Date()
        } else {
            self.habit.timerStartDate = nil
        }
    }
    
    func checkForDate() {
        if let date = self.habit.timerStartDate, let context = self.context {
            let difference = Date().timeIntervalSince(date)
            withAnimation {
                self.habit.addToHabit(Int(difference), date: Date().adjustedForNightOwl(), context: context)
                
                self.habit.objectWillChange.send()
            }
            
            start()
        }
        
//        let test: Decimal = 5
//        let hm = test.
    }
    
    func shouldStart() {
        if self.habit.timerStartDate != nil {
            start()
        }
    }
}
