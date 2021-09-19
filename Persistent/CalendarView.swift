//
//  CalendarView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 25.05.21.
//

import SwiftUI
import CoreData

struct CalendarView: View {
    // PresentationMode Workaround
    @Binding var toggle: Bool
    
    let habit: HabitItem
    
    let columns = [
        GridItem(.adaptive(minimum: 50, maximum: 80)),
        GridItem(.adaptive(minimum: 50, maximum: 80)),
        GridItem(.adaptive(minimum: 50, maximum: 80)),
        GridItem(.adaptive(minimum: 50, maximum: 80)),
        GridItem(.adaptive(minimum: 50, maximum: 80)),
        GridItem(.adaptive(minimum: 50, maximum: 80)),
        GridItem(.adaptive(minimum: 50, maximum: 80))
    ]
    
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
    
    var days: [Date] {
        let cal = Calendar.current
        let nsCal = cal as NSCalendar
        
        let components = nsCal.components([.year, .month, .weekday, .day], from: date)
        
        let year = components.year
        let month = components.month
        
        let weekRange = nsCal.range(of: .weekOfMonth, in: .month, for: date)
        
        let weeks = weekRange.length
        
        let totalCells = weeks * 7
        
        var dates: [Date] = []
        var firstDate = dateFormatter.date(from: "\(year!)-\(month!)-1")!
        
        let componentsFirstDate = nsCal.components([.year, .month, .weekday, .day], from: firstDate)
        
        firstDate = nsCal.date(byAdding: [.day], value: -(componentsFirstDate.weekday! - 2), to: firstDate, options: [])!
        
        for _ in 0 ..< totalCells {
            dates.append(firstDate)
            firstDate = nsCal.date(byAdding: [.day], value: 1, to: firstDate, options: [])!
        }
        
        
        return dates
    }
    
    var titles: [String] {
        var titles: [String] = []
        
        titles.append("Mon")
        titles.append("Tue")
        titles.append("Wed")
        titles.append("Thu")
        titles.append("Fri")
        titles.append("Sat")
        titles.append("Sun")
        
        return titles
    }
    
    func relevantCount(date: Date) -> Int {
        let todayCount: [HabitCompletionDate]
        todayCount = habit.dateArray.filter { Calendar.current.isDate($0.date!, equalTo: date, toGranularity: .day) }
        return todayCount.count
    }
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns) {
                ForEach(titles, id: \.self) { title in
                    Text(title)
                        .font(.headline)
                }
                
                ForEach(days, id: \.self) { date in
                    ZStack {
                        Circle()
                            .fill(Color(UIColor.systemGray6))
                            .scaledToFit()
                        
                        Text(stringFormatter.string(from: date))
                            .font(.headline)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(relevantCount(date: date)) / CGFloat(habit.amountToDo))
                            .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .rotation(.degrees(270))
                            .foregroundColor(habit.iconColor)
                    }
                    .onTapGesture {
                        habitDate = date
                        toggle.toggle()
                    }
                }
            }
            .padding()
        }
    }
}

struct CalendarPagerView: View {
    let habit: HabitItem
    @Binding var date: Date
    
    let radius: Int = 1001
    
    func getMonth(_ index: Int) -> Date {
        var date = Date()
        
        let cal = Calendar.current as NSCalendar
        
        var toAdd = Int(Float(radius / 2).rounded(.down))
        toAdd = index - (toAdd + 1)
        
        date = cal.date(byAdding: [.month], value: toAdd, to: date, options: [])!
        
        return date
    }
    
    func getMonthName(date: Date) -> String {
        let formatter  = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: date)
    }
    
    @State var index: Int = 501
    
    @Binding var toggle: Bool
    
    let animation: Animation = .interpolatingSpring(stiffness: 400, damping: 28)
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(width: 50, height: 5)
                .foregroundColor(Color(UIColor.systemGray2))
                .padding(.bottom)
            
            HStack {
                Image(systemName: "chevron.left.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        withAnimation {
                            index -= 1
                        }
                    }
                Spacer()
                
                Text(getMonthName(date: getMonth(index)))
                    .font(.title.weight(.bold))
                    .id(index)
                    .transition(.identity)
                    
                
                Spacer()
                
                Image(systemName: "chevron.right.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .onTapGesture {
                        withAnimation {
                            index += 1
                        }
                    }
            }
            .frame(minHeight: 30, maxHeight: 30)
            .padding(.horizontal)
            
            TabView(selection: $index) {
                ForEach(0 ..< radius, id: \.self) { index in
                    VStack {
                        CalendarView(toggle: $toggle, habit: habit, date: getMonth(index), habitDate: $date)
                        Spacer()
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
        }
    }
}



struct CalendarView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    static var previews: some View {
        var testHabit: HabitItem {
        
            let testItem: HabitItem = HabitItem(context: moc)
            testItem.habitName = "Test"
            testItem.amountToDo = 3
            testItem.resetIntervalEnum = .monthly
            
            let anotherNewItem = HabitCompletionDate(context: moc)
            anotherNewItem.date = Date()
            
            let secondNewItem = HabitCompletionDate(context: moc)
            secondNewItem.date = Date()
            testItem.date = NSSet(array: [anotherNewItem, secondNewItem])
            
            return testItem
        }
        return CalendarPagerView(habit: testHabit, date: .constant(Date()), toggle: .constant(false))
    }
}
