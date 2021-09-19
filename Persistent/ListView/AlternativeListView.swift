//
//  AlternativeListView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 13.08.21.
//

import SwiftUI
import CoreData

struct AlternativeListView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.habitName, ascending: true)],
        animation: .default) var habitItems: FetchedResults<HabitItem>
    @Namespace var namespace
    @State var show: Bool = false
    
    @State var chosenHabit: HabitItem = HabitItem()
    
    private let animation: Animation = .interpolatingSpring(stiffness: 400, damping: 30)
    private let backAnimation: Animation = .interpolatingSpring(stiffness: 600, damping: 40)
    
    var body: some View {
        ZStack {
            if !show {
                ScrollView {
                    ForEach(habitItems, id: \.id) { habit in
                        HStack {
                            if habit.iconName != nil {
                                ZStack {
                                    Image(habit.iconName!)
                                        .resizable()
                                    
                                    //iconColors[item.iconColorIndex].blendMode(.sourceAtop)
                                }
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 40)
                                    //.padding(.trailing, 5)
                            }
                            
                            Text(habit.habitName)
                                .font(.title)
                                .fontWeight(.semibold)
                                .matchedGeometryEffect(id: habit.habitName, in: namespace)
                            
                            Spacer()
                            
                            ZStack {
                                Text("\(relevantCount(habit: habit))/\(habit.amountToDo)")
                                    .fontWeight(.bold)
                                CircleProgressBar(progress: CGFloat(relevantCount(habit: habit)) / CGFloat(habit.amountToDo), strokeWidth: 7)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 50)
                            }
                            .matchedGeometryEffect(id: "progressBar: \(habit.habitName)", in: namespace)
                            .padding(.trailing)
                            .padding(.vertical, 3)
                        }
                        .padding(6)
                        .background(Color(UIColor.systemBackground)
                                        .cornerRadius(15)
                                        .shadow(color: .primary.opacity(0.4), radius: 10, x: 0, y: 0)
                                        .matchedGeometryEffect(id: "background: \(habit.habitName)", in: namespace))
                        .onTapGesture {
                            withAnimation(animation) {
                                show.toggle()
                                print(habit)
                                chosenHabit = habit
                            }
                        }
                        .padding()
                    }
                }
            } else {
                VStack {
                    Text(chosenHabit.habitName)
                        .font(.title)
                        .fontWeight(.semibold)
                        .matchedGeometryEffect(id: chosenHabit.habitName, in: namespace)
                        .padding()
                    
                    ZStack {
                        Text("\(relevantCount(habit: chosenHabit))/\(chosenHabit.amountToDo)")
                            .font(.title)
                            .fontWeight(.bold)
                        CircleProgressBar(progress: CGFloat(relevantCount(habit: chosenHabit)) / CGFloat(chosenHabit.amountToDo), strokeWidth: 14)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                    }
                    .matchedGeometryEffect(id: "progressBar: \(chosenHabit.habitName)", in: namespace)
                    
                    Spacer()
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Color(UIColor.systemBackground)
                                .cornerRadius(15)
                                .shadow(color: .primary.opacity(0.4), radius: 10, x: 0, y: 0)
                                .matchedGeometryEffect(id: "background: \(chosenHabit.habitName)", in: namespace))
                .onTapGesture {
                    withAnimation(backAnimation) {
                        show.toggle()
                        print("other")
                    }
                }
                .padding()
            }
        }
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

struct AlternativeListView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    static var previews: some View {
        var testHabit: HabitItem {
        
            let testItem: HabitItem = HabitItem(context: moc)
            testItem.habitName = "Test"
            testItem.amountToDo = 3
            testItem.resetIntervalEnum = .monthly
            testItem.id = UUID()
            testItem.iconColorIndex = 0
            testItem.habitDeleted = false
            
            let anotherNewItem = HabitCompletionDate(context: moc)
            anotherNewItem.date = Date()
            
            let secondNewItem = HabitCompletionDate(context: moc)
            secondNewItem.date = Date()
            testItem.date = NSSet(array: [anotherNewItem, secondNewItem])
            
            return testItem
        }
        return AlternativeListView()
            .environment(\.managedObjectContext, moc)
    }
}
