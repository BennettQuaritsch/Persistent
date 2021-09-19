//
//  HabitListCell.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 16.06.21.
//

import SwiftUI
import CoreData

struct HabitListCell: View {
    var item: HabitItem
    
    var body: some View {
        HStack {
            if item.iconName != nil {
                ZStack {
                    Image(item.iconName!)
                        .resizable()
                        .foregroundColor(item.iconColor)
                }
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
                    //.padding(.trailing, 5)
            }
            
            Text(item.habitName)
                .font(.title)
                .fontWeight(.semibold)
                .lineLimit(2)
                .minimumScaleFactor(0.4)
                .truncationMode(.tail)
            
            Spacer()
            
            ZStack {
                Text("\(relevantCount(habit: item))/\(item.amountToDo)")
                    .fontWeight(.bold)
                NewProgressBar(strokeWidth: 7, progress: CGFloat(relevantCount(habit: item)) / CGFloat(item.amountToDo), color: item.iconColor)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
            }
            .padding(.trailing)
            .padding(.vertical, 3)
        }
        .padding(.horizontal, 5)
        .padding(10)
        .background(Color.primary.colorInvert())
        .cornerRadius(20)
        .shadow(color: .primary.opacity(0.2), radius: 6, x: 0, y: 0)
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    func relevantCount(habit: HabitItem) -> Int {
        let todayCount: [HabitCompletionDate]
        switch habit.resetIntervalEnum {
        case .daily:
            todayCount = habit.dateArray.filter { Calendar.current.isDateInToday($0.date!) }
        case .weekly:
            todayCount = habit.dateArray.filter { Calendar.current.isDate($0.date!, equalTo: Date(), toGranularity: .weekOfYear) }
        case .monthly:
            todayCount = habit.dateArray.filter { Calendar.current.isDate($0.date!, equalTo: Date(), toGranularity: .month) }
        }
        return todayCount.count
    }
}

struct HabitListCell_Previews: PreviewProvider {
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
        return NavigationView {HabitListCell(item: testHabit)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }.previewLayout(.sizeThatFits)
    }
}
