//
//  LineChartView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 08.10.21.
//

import SwiftUI

struct HabitLineChartView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    init(habit: HabitItem) {
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
        
        self.habit = habit
    }
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        
        return formatter
    }
    
    var habit: HabitItem
    
    var dates: [Date]
    @State var data: [Int] = [0]
    @State var maxValue = 1
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                LinePath(data: data)
                    .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                    .foregroundColor(habit.iconColor)
            }
            
            HStack {
                ForEach(dates, id: \.self) { date in
                    Text(date.formatted(.dateTime.weekday(.short)))
                        .font(.headline)
                }
                .frame(minWidth: 10, maxWidth: .infinity)
            }
            .padding(.top, 8)
        }
        .onAppear {
            var countArray: [Int] = []
            
            for date in dates {
//                let filteredDates = habit.dateArray.filter { Calendar.current.isDate($0.date!, equalTo: date, toGranularity: .day) }
//                print(filteredDates)
//                countArray.append(filteredDates.count)
                
                if let tempDate = habit.date?.first(where: { Calendar.defaultCalendar.isDate($0.date!, equalTo: date, toGranularity: .day) }) {
                    countArray.append(Int(tempDate.habitValue))
                } else {
                    countArray.append(0)
                }
            }
            
            withAnimation(.easeInOut) {
                data = countArray
                
                if let max = countArray.max() {
                    if max > 0 && max > habit.amountToDo{
                        maxValue = max
                    } else {
                        maxValue = Int(habit.amountToDo)
                    }
                }
            }
        }
    }
    
    struct LinePath: Shape {
        var data: [Int]
        
        var animatableData: [Int] {
            get { data }
            set { self.data = newValue }
        }
        
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            let max = CGFloat(data.max() ?? 1)
            let count = CGFloat(data.count)
            
            let step = CGPoint(x: rect.width / (count - 1), y: -(rect.height / max))
            
            var p1 = CGPoint(x: 0, y: (step.y * CGFloat(data.first ?? 0)) + rect.height)
            path.move(to: p1)
            
            for index in data.indices {
                let p2 = CGPoint(x: step.x * CGFloat(index), y: step.y * CGFloat(data[index]) + rect.height)
                let midPoint = CGPoint.midPointForPoints(p1: p1, p2: p2)
                
                path.addQuadCurve(to: midPoint, control: CGPoint.controlPointForPoints(p1: midPoint, p2: p1))
                path.addQuadCurve(to: p2, control: CGPoint.controlPointForPoints(p1: midPoint, p2: p2))
                
                p1 = p2
                //path.addLine(to: p2)
                //path.addEllipse(in: CGRect(origin: point, size: CGSize(width: 5, height: 5)))
            }
            
            return path
        }
    }
}

struct HabitLineChartView_Previews: PreviewProvider {
    static var previews: some View {
        return HabitLineChartView(habit: PersistenceController.preview.container.viewContext.registeredObjects.first(where: { $0 is HabitItem }) as! HabitItem)
    }
}
