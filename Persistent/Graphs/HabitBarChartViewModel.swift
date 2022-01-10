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
        case weekly = "Week"
        case monthly = "Month"
        
        var localizedName: LocalizedStringKey { LocalizedStringKey(rawValue) }
    }
    
    @Published var data: [Int] = [0, 0, 0, 0, 0, 0, 0]
    @Published var maxValue: Int = 1
    
    @Published var dates: [Date]
    
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
    
    func loadDailyHabits() {
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
        
        var countArray: [Int] = []
        
        for date in dates {
            countArray.append(habit.relevantCountDaily(date))
        }
        
        if let max = countArray.max() {
            if max > 0 && max > habit.amountToDo{
                maxValue = max
            } else {
                maxValue = Int(habit.amountToDo)
            }
        }
        
        data = countArray.map { _ in return 0 }
        
        withAnimation(.easeInOut) {
            data = countArray
        }
    }
    
    func loadMonthlyHabits() {
        let cal = Calendar.defaultCalendar
        
        var dates: [Date] = []
        
        let startOfMonth = cal.dateComponents([.calendar, .year, .month], from: Date()).date!
        let endOfMonth = cal.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        self.shownDates = [startOfMonth, endOfMonth]
        
        var date = startOfMonth
        
        while date <= endOfMonth {
            dates.append(date)
            
            guard let newDate = cal.date(byAdding: .day, value: 1, to: date) else { break }
            
            date = newDate
        }
        
        print("monthly: \(dates)")
        
        self.dates = dates
        
        var countArray: [Int] = []
        
        for date in dates {
//            let filteredDates = habit.dateArray.filter { Calendar.current.isDate($0.date!, equalTo: date, toGranularity: .day) }
//            print(filteredDates)
//            countArray.append(filteredDates.count)
            if let date = habit.date?.first(where: { Calendar.defaultCalendar.isDate($0.date!, equalTo: date, toGranularity: .day) }) {
                countArray.append(Int(date.habitValue))
            } else {
                countArray.append(0)
            }
        }
        
        print("countarray: \(countArray)")
        
        if let max = countArray.max() {
            if max > 0 && max > habit.amountToDo{
                maxValue = max
            } else {
                maxValue = Int(habit.amountToDo)
            }
        }
        
        data = countArray.map { _ in return 0 }
        
        withAnimation(.easeInOut) {
            data = countArray
            
            
        }
    }
    
    func loadHabitsForWeeklyHabit() {
        let cal = Calendar.defaultCalendar
        var countArray: [Int] = []
        
        let year = cal.component(.year, from: Date())
        // Get the first day of next year
        if let firstOfYear = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1)) {
            var currentDate = firstOfYear
            
            for _ in 1 ... weeks(in: year) {
                countArray.append(habit.relevantCount(currentDate))
                currentDate = cal.date(byAdding: .weekOfYear, value: 1, to: currentDate)!
            }
        }
        
        if let max = countArray.max() {
            if max > 0 && max > habit.amountToDo {
                maxValue = max
            } else {
                maxValue = Int(habit.amountToDo)
            }
        }
        
        data = countArray.map { _ in return 0 }
        
        withAnimation(.easeInOut) {
            data = countArray
        }
    }
    
    private func weeks(in year: Int) -> Int {
        func p(_ year: Int) -> Int {
            return (year + year/4 - year/100 + year/400) % 7
        }
        return (p(year) == 4 || p(year-1) == 3) ? 53 : 52
    }
    
    //
    func numberOfWeeksInMonth(_ date: Date) -> Int {
         var calendar = Calendar(identifier: .gregorian)
         calendar.firstWeekday = 1
         let weekRange = calendar.range(of: .weekOfMonth,
                                        in: .month,
                                        for: date)
         return weekRange!.count
    }
}
