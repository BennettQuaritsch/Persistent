//
//  CalendarView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 25.05.21.
//

import SwiftUI
import CoreData

extension Calendar {

//    func generateDates(inside interval: DateInterval,
//                       matching components: DateComponents) -> [Date] {
//       var dates: [Date] = []
//       dates.append(interval.start)
//
//       enumerateDates(
//           startingAfter: interval.start,
//           matching: components,
//           matchingPolicy: .nextTime) { date, _, stop in
//           if let date = date {
//               if date < interval.end {
//                   dates.append(date)
//               } else {
//                   stop = true
//               }
//           }
//       }
//
//       return dates
//    }

}

extension Date {
    func startOfWeek(calendar: Calendar = Calendar.defaultCalendar) -> Date? {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        guard let date = calendar.date(from: components) else { return nil }
        return date
    }
    
    func endOfWeek(calendar: Calendar = Calendar.defaultCalendar) -> Date? {
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        guard let date = calendar.date(from: components) else { return nil }
        return calendar.date(byAdding: .day, value: 7, to: date)
    }
}

struct CalendarView: View {
    // PresentationMode Workaround
    @Binding var toggle: Bool
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.calendar) var calendar
    
    let habit: HabitItem
    
    @State private var columns: [GridItem] = Array.init(repeating: GridItem(.flexible()), count: 7)
    
    var dateFormatter: DateFormatter = {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var stringFormatter: DateFormatter = {
        let formatter  = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter
    }()
    
    var date: Date
    @Binding var habitDate: Date
    
    var dates: [Date] {
//        var calendar = Calendar.current
//        let prefLanguage = Locale.preferredLanguages[0]
//        calendar.locale = .init(identifier: prefLanguage)
        
        let interval = calendar.dateInterval(of: .month, for: date)!
        
        var dates: [Date] = []
        
        let startDate = interval.start
        let endDate = interval.end
        
        // Generiere die Dates vom Beginn und Ende der Woche, damit die Reste der Wochen noch im Kalendar zu sehen sind
        let newInterval = DateInterval(start: startDate.startOfWeek()!, end: endDate.endOfWeek()!)
        let generatedDates = calendar.generateDates(inside: newInterval, matching: DateComponents(hour: 0, minute: 0, second: 0))
        dates.append(contentsOf: generatedDates)
        
        return dates
    }
    
    var titles: [String] {
        var titles: [String] = []
        
//        var calendar = Calendar.current
//        let prefLanguage = Locale.preferredLanguages[0]
//        calendar.locale = .init(identifier: prefLanguage)
        
        //titles = calendar.shortWeekdaySymbols.map { $0.trimmingCharacters(in: .alphanumerics.inverted) }
        for index in 1...7 {
            titles.append(weekdayNameFrom(weekdayNumber: index).trimmingCharacters(in: .alphanumerics.inverted))
        }
        
        return titles
    }
    
    func getMonthName(date: Date) -> String {
        let formatter  = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: horizontalSizeClass == .regular ? 25 : 10) {
                ForEach(titles, id: \.self) { title in
                    Text(title)
                        .font(.headline)
                        .fontWeight(.heavy)
                }
                
                ForEach(dates, id: \.self) { date in
                    ZStack {
                        Circle()
                            #if os(iOS)
                            .fill(calendar.isDate(date, equalTo: self.date, toGranularity: .month) ? Color(colorScheme == .dark ? "secondarySystemGroupedBackground" : "systemGray6") : Color.clear)
                            .overlay(
                                VStack {
                                    Spacer()
                                    
                                    if calendar.isDate(date, equalTo: Date(), toGranularity: .day) {
                                        Circle()
                                            .fill(Color.accentColor)
                                            .frame(width: 5, height: 5)
                                            .padding(.bottom, 6)
                                    }
                                }
                            )
                            #endif
                            .scaledToFit()
                        
                        if calendar.isDate(habitDate, equalTo: date, toGranularity: .day) {
                            Circle()
                                .fill(habit.iconColor.opacity(0.3))
                        }
                        
                        Text(stringFormatter.string(from: date))
                            .font(.headline)
                            .foregroundColor(calendar.isDate(date, equalTo: self.date, toGranularity: .month) ? .primary : .gray)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(habit.relevantCountDaily(date)) / CGFloat(habit.amountToDo))
                            .stroke(style: StrokeStyle(lineWidth: horizontalSizeClass == .regular ? 6 : 3, lineCap: .round))
                            .rotation(.degrees(270))
                            .foregroundColor(habit.iconColor)
                    }
                    .onTapGesture {
                        habitDate = date
                        toggle.toggle()
                    }
                }
            }
            .onAppear {
                columns = Array.init(repeating: GridItem(.flexible(), spacing: horizontalSizeClass == .regular ? 25 : 10), count: 7)
            }
            
            Spacer()
        }
        .padding(.top)
        .padding(.horizontal, horizontalSizeClass == .regular ? 50 : 10)
    }
}



struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = PersistenceController().container.viewContext
        
        let habit = HabitItem(context: moc)
        habit.id = UUID()
        habit.habitName = "PreviewTest"
        habit.iconName = iconSections.randomElement()!.iconArray.randomElement()!
        habit.resetIntervalEnum = .daily
        habit.amountToDo = 4
        habit.iconColorIndex = Int16(iconColors.firstIndex(of: iconColors.randomElement()!)!)
        
        for _ in 1...Int.random(in: 1...6) {
            let date = HabitCompletionDate(context: moc)
            date.date = Date()
            date.item = habit
        }
        
        return CalendarView(toggle: .constant(true), habit: habit, date: Date(), habitDate: .constant(Date()))
    }
}
