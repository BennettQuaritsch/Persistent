//
//  HabitBarChartViewModel.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 13.10.21.
//

import Foundation
import SwiftUI

class HabitBarChartViewModel: ObservableObject {
    enum GraphPickerSelectionEnum: String, Equatable, CaseIterable {
        case smallView
        case mediumView
        
        func name(habit: HabitItem) -> String {
            switch habit.resetIntervalEnum {
            case .daily:
                switch self {
                case .smallView:
                    return "Weekly"
                case .mediumView:
                    return "Monthly"
                }
            case .weekly:
                switch self {
                case .smallView:
                    return "Last 7 weeks"
                case .mediumView:
                    return "Last 25 weeks"
                }
            case .monthly:
                switch self {
                case .smallView:
                    return "Last 6 months"
                case .mediumView:
                    return "Last 12 months"
                }
            }
        }
    }
    
    var localizedName: LocalizedStringKey {
        switch habit.resetIntervalEnum {
        case .daily:
            switch graphPickerSelection {
            case .smallView:
                return "Week"
            case .mediumView:
                return "month"
            }
        case .weekly:
            switch graphPickerSelection {
            case .smallView:
                return "Last 7 Weeks"
            case .mediumView:
                return "Last 25 Weeks"
            }
        default:
            return "Test"
        }
    }
    
    @Published var graphPickerSelection: HabitBarChartViewModel.GraphPickerSelectionEnum = .smallView
    
    @Published var data: [Int] = [0, 0, 0, 0, 0, 0, 0]
    @Published var maxValue: Int = 1
    
    @Published var dates: [Date]
    
    var currentDate = Date()
    @Published var shownDates: [Date]
    
    @Published var habit: HabitItem
    
    init(habit: HabitItem) {
        // Datum des Wochenanfangs heraussuchen, zusammen mit den nächsten sechs Tagen in einen Array
        let cal = Calendar.defaultCalendar
        
        var dates: [Date] = []
        
        let startOfWeek = cal.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: Date()).date
        
        if let startOfWeek = startOfWeek {
            dates.append(startOfWeek)
            
            for index in 1...6 {
                dates.append(cal.date(byAdding: .day, value: index, to: startOfWeek)!)
            }
        }
        
        self.dates = dates
        self.shownDates = dates
        
        self.habit = habit
    }
    
    
    func loadHabits(_ selection: GraphPickerSelectionEnum = .smallView, animated: Bool = true) {
        let cal = Calendar.defaultCalendar
        var countArray: [Int] = []
        
        if selection == .smallView {
            var currentDate = self.currentDate
            
            self.shownDates = []
            
            var barCount: Int
            var calendarCompnent: Calendar.Component
            
            switch habit.resetIntervalEnum {
            case .daily:
                barCount = 7
                calendarCompnent = .day
            case .weekly:
                barCount = 6
                calendarCompnent = .weekOfYear
            case .monthly:
                barCount = 6
                calendarCompnent = .month
            }
            
            for _ in 1 ... barCount {
                self.shownDates.append(currentDate)
//                countArray.append(habit.relevantCount(currentDate))
                currentDate = cal.date(byAdding: calendarCompnent, value: -1, to: currentDate)!
            }
            
            self.shownDates = self.shownDates.reversed()
            
            countArray = self.shownDates.map { return habit.relevantCount($0) }
        } else {
            var currentDate = self.currentDate
            
            self.shownDates = []
            
            var barCount: Int
            var calendarCompnent: Calendar.Component
            
            switch habit.resetIntervalEnum {
            case .daily:
                barCount = 31
                calendarCompnent = .day
            case .weekly:
                barCount = 25
                calendarCompnent = .weekOfYear
            case .monthly:
                barCount = 12
                calendarCompnent = .month
            }
            
            for _ in 1 ... barCount {
                self.shownDates.append(currentDate)
//                countArray.append(habit.relevantCount(currentDate))
                currentDate = cal.date(byAdding: calendarCompnent, value: -1, to: currentDate)!
            }
            
            self.shownDates = self.shownDates.reversed()
            
            countArray = self.shownDates.map { return habit.relevantCount($0) }
        }
        
        
        if let max = countArray.max() {
            if max > 0 && max > habit.amountToDo {
                maxValue = max
            } else {
                maxValue = Int(habit.amountToDo)
            }
        }
        
        data = countArray.map { _ in return 0 }
        
        if animated {
            withAnimation {
                data = countArray
            }
        } else {
            data = countArray
        }
    }
    
    func changeSelectedInterval(negative: Bool = false) {
        let cal = Calendar.defaultCalendar
        
        var component: Calendar.Component
        var value: Int
        
        switch self.habit.resetIntervalEnum {
        case .daily:
            component = .day
            switch self.graphPickerSelection {
            case .smallView:
                value = 7
            case .mediumView:
                value = 31
            }
        case .weekly:
            component = .weekOfYear
            switch self.graphPickerSelection {
            case .smallView:
                value = 6
            case .mediumView:
                value = 25
            }
        case .monthly:
            component = .month
            switch self.graphPickerSelection {
            case .smallView:
                value = 6
            case .mediumView:
                value = 12
            }
        }
        
        var transaction = Transaction()
        transaction.disablesAnimations = true
        
        if let date = cal.date(byAdding: component, value: negative ? -value : value, to: self.currentDate) {
            self.currentDate = date
            self.loadHabits(self.graphPickerSelection, animated: false)
        }
    }
}
