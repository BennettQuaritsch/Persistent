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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme
    
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
                
                ForEach(days, id: \.self) { date in
                    ZStack {
                        Circle()
                            #if os(iOS)
                            .fill(Color(colorScheme == .dark ? "secondarySystemGroupedBackground" : "systemGray6"))
                            #endif
                            .scaledToFit()
                        
                        if Calendar.current.isDate(habitDate, equalTo: date, toGranularity: .day) {
                            Circle()
                                .fill(habit.iconColor.opacity(0.4))
                        }
                        
                        Text(stringFormatter.string(from: date))
                            .font(.headline)
                        
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
        NavigationView {
            VStack {
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
                
//                TabView(selection: $index) {
//                    ForEach(0 ..< radius, id: \.self) { index in
//                        VStack {
//                            CalendarView(toggle: $toggle, habit: habit, date: getMonth(index), habitDate: $date)
//                            Spacer()
//                        }
//                    }
//                }
//                #if os(iOS)
//                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
//                #endif
                
                VStack {
                    CalendarView(toggle: $toggle, habit: habit, date: getMonth(index), habitDate: $date)
                    Spacer()
                }
                .id(UUID())
                .transition(.identity)
                
                
            }
            .padding(.top)
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        toggle = false
                    } label: {
                        Text("Close")
                    }
                }
            }
        }
    }
}



struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = PersistenceController().container.viewContext
        
        let habit = HabitItem(context: moc)
        habit.id = UUID()
        habit.habitName = "PreviewTest"
        habit.iconName = iconChoices.randomElement()!
        habit.resetIntervalEnum = .daily
        habit.amountToDo = 4
        habit.iconColorIndex = Int16(iconColors.firstIndex(of: iconColors.randomElement()!)!)
        
        for _ in 1...Int.random(in: 1...6) {
            let date = HabitCompletionDate(context: moc)
            date.date = Date()
            date.item = habit
        }
        
        return CalendarPagerView(habit: habit, date: .constant(Date()), toggle: .constant(false))
    }
}
