//
//  ChartModel.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 16.08.22.
//

import Foundation
import SwiftUI

class ChartModel: ObservableObject {
    @Published private(set) var chartValues: [Int]
    
    @Published private(set) var chartDates: [Date]
    
    @Published private(set) var maxValue: Int
    
    @Published var graphPickerSelection: ChartModel.GraphPickerSelectionEnum = .smallView
    
    init() {
        self.chartValues = [0, 0, 0, 0, 0, 0, 0]
        self.chartDates = []
        self.maxValue = 1
    }
    
    init(chartValues: [Int], chartDates: [Date], maxValue: Int) {
        self.chartValues = chartValues
        self.chartDates = chartDates
        self.maxValue = maxValue
    }
    
    func loadBarChart(for habit: HabitItem, graphSize: GraphPickerSelectionEnum, animation: Animation? = .easeOut(duration: 0.4)) {
        let cal = Calendar.defaultCalendar
        var array: [Date] = []
        
        let componentToAdd: Calendar.Component
        let amount: Int
        
        switch graphSize {
        case .smallView:
            componentToAdd = .day
            amount = 7
        case .mediumView:
            componentToAdd = .weekOfYear
            amount = 8
        case .bigView:
            componentToAdd = .month
            amount = 12
        }
        
        var tempDate = Date().adjustedForNightOwl()
        
        for _ in 0 ..< amount {
            array.append(tempDate)
            tempDate = tempDate.changeDate(with: cal, byAdding: componentToAdd, value: -1)
        }
        
        self.chartDates = array.reversed()
        
        let chartValues = array.reversed().map { graphSize.habitRelevantCount(for: habit, date: $0) }
        
//        self.maxValue = max(chartValues.max() ?? 1, habit.wrappedAmountToDo)
        if let chartValuesMax = chartValues.max(), chartValuesMax > 0 {
            self.maxValue = chartValuesMax
        } else {
            self.maxValue = habit.wrappedAmountToDo
        }
        
        
        if let animation {
            self.chartValues = chartValues.map { _ in 0 }
            withAnimation(animation) {
                self.chartValues = chartValues
            }
        } else {
            self.chartValues = chartValues
        }
        
    }
    
    enum GraphPickerSelectionEnum: String, Equatable, CaseIterable {
        case smallView
        case mediumView
        case bigView
        
        func habitRelevantCount(for habit: HabitItem, date: Date) -> Int {
            let calendar: Calendar = Calendar.defaultCalendar
            
            var count: Int = 0
            
            switch self {
            case .smallView:
                count = habit.date?.first(where: { calendar.isDate($0.date!, equalTo: date, toGranularity: .day) })?.wrappedHabitValue ?? 0
            case .mediumView:
                let dateItemsInWeek = habit.date?.filter { calendar.isDate($0.date!, equalTo: date, toGranularity: .weekOfYear) }
                
                if let dateItemsInWeek = dateItemsInWeek {
                    for dateItemInWeek in dateItemsInWeek {
                        count += dateItemInWeek.wrappedHabitValue
                    }
                }
            case .bigView:
                let dateItemsInMonth = habit.date?.filter { calendar.isDate($0.date!, equalTo: date, toGranularity: .month) }
                
                if let dateItemsInMonth = dateItemsInMonth {
                    for dateItemInMonth in dateItemsInMonth {
                        count += dateItemInMonth.wrappedHabitValue
                    }
                }
            }
            
            return count
        }
    }
    
    func getSuccessfulCompletions(for habit: HabitItem) -> Int {
        let cal = Calendar.defaultCalendar
        
        guard let dateYearAgo = cal.date(byAdding: .year, value: -1, to: Date().adjustedForNightOwl()) else { return 0 }
        
        guard let dates = habit.date else { return 0 }
        
        let datesInYear = dates.filter { $0.wrappedDate > dateYearAgo }
        
        switch habit.resetIntervalEnum {
        case .daily:
            let filteredDates = datesInYear.filter { $0.wrappedHabitValue >= habit.wrappedAmountToDo }
            return filteredDates.count
        case .weekly:
            var tempDate = dateYearAgo
            
            var amount: Int = 0
            
            while tempDate < Date().adjustedForNightOwl() {
                let filteredDates = datesInYear.filter { cal.isDate(tempDate, equalTo: $0.wrappedDate, toGranularity: .weekOfYear) }
                if filteredDates.reduce(0, { $0 + $1.wrappedHabitValue }) >= habit.wrappedAmountToDo {
                    amount += 1
                }
                tempDate = tempDate.changeDate(with: cal, byAdding: .weekOfYear, value: 1)
            }
            
            return amount
        case .monthly:
            var tempDate = dateYearAgo
            
            var amount: Int = 0
            
            while tempDate < Date().adjustedForNightOwl() {
                let filteredDates = datesInYear.filter { cal.isDate(tempDate, equalTo: $0.wrappedDate, toGranularity: .month) }
                print("filtered: \(filteredDates.map {$0.wrappedDate})")
                
                if filteredDates.reduce(0, { $0 + $1.wrappedHabitValue }) >= habit.wrappedAmountToDo {
                    amount += 1
                }
                tempDate = tempDate.changeDate(with: cal, byAdding: .month, value: 1)
            }
            
            return amount
        }
    }
    
    func getPercentageDone(for habit: HabitItem) -> Double {
        let cal = Calendar.defaultCalendar
        
        guard let dateYearAgo = cal.date(byAdding: .year, value: -1, to: Date().adjustedForNightOwl()) else { return 0 }
        
        guard let dates = habit.date else { return 0 }
        
        let datesInYear = dates.filter { $0.wrappedDate > dateYearAgo }
        
        switch habit.resetIntervalEnum {
        case .daily:
            let filteredDates = datesInYear.filter { $0.wrappedHabitValue >= habit.wrappedAmountToDo }
            return (Double(filteredDates.count) / Double(cal.dateComponents([.day], from: dateYearAgo, to: Date().adjustedForNightOwl()).day ?? 365)) * 100
        case .weekly:
            var tempDate = dateYearAgo
            
            var amount: Int = 0
            var interval: Int = 0
            
            while tempDate < Date().adjustedForNightOwl() {
                let filteredDates = datesInYear.filter { cal.isDate(tempDate, equalTo: $0.wrappedDate, toGranularity: .weekOfYear) }
                if filteredDates.reduce(0, { $0 + $1.wrappedHabitValue }) >= habit.wrappedAmountToDo {
                    amount += 1
                }
                interval += 1
                tempDate = tempDate.changeDate(with: cal, byAdding: .weekOfYear, value: 1)
            }
            
            return (Double(amount) / Double(interval)) * 100
        case .monthly:
            var tempDate = dateYearAgo
            
            var amount: Int = 0
            var interval: Int = 0
            
            while tempDate < Date().adjustedForNightOwl() {
                let filteredDates = datesInYear.filter { cal.isDate(tempDate, equalTo: $0.wrappedDate, toGranularity: .month) }
                print("filtered: \(filteredDates.map {$0.wrappedDate})")
                
                if filteredDates.reduce(0, { $0 + $1.wrappedHabitValue }) >= habit.wrappedAmountToDo {
                    amount += 1
                }
                interval += 1
                tempDate = tempDate.changeDate(with: cal, byAdding: .month, value: 1)
            }
            
            return (Double(amount) / Double(interval)) * 100
        }
        
        
    }
}
