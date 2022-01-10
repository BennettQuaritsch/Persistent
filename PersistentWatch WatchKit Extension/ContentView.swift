//
//  ContentView.swift
//  PersistentWatch WatchKit Extension
//
//  Created by Bennett Quaritsch on 06.01.22.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.habitName, ascending: true)], predicate: nil, animation: .default) var habits: FetchedResults<HabitItem>
    
    var body: some View {
        VStack {
//            Button("Add") {
//                let habit = HabitItem(context: viewContext)
//                habit.id = UUID()
//                habit.habitName = "PreviewTest"
//                habit.iconName = iconSections.randomElement()!.iconArray.randomElement()!
//                habit.resetIntervalEnum = .daily
//                habit.amountToDo = 4
//                habit.iconColorIndex = Int16(iconColors.firstIndex(of: iconColors.randomElement()!)!)
//                
//                let dateItem = HabitCompletionDate(context: viewContext)
//                dateItem.date = Date()
//                dateItem.habitValue = Int32(Int.random(in: 1...7))
//                dateItem.item = habit
//                
//                print(habit)
//                
//                
//                do {
//                    try viewContext.save()
//                    
//                    print("done")
//                } catch {
//                    fatalError()
//                }
//            }
            
            List {
                ForEach(habits) { habit in
                    NavigationLink(destination: WatchHabitDetailView(habit: habit)) {
                        HStack {
                            Text(habit.habitName)
                                .minimumScaleFactor(0.6)

                            Spacer()

                            ProgressBar(strokeWidth: 5, progress: CGFloat(habit.relevantCount()) / CGFloat(habit.amountToDo), color: habit.iconColor)
                                .frame(width: 30)
                                .background(
                                    Circle()
                                        .stroke(Color(white: 0), lineWidth: 5)
                                )
                                .overlay(
                                    Text("\(habit.relevantCount())")
                                )
                                .padding(5)

            //                Circle()
            //                    .fill(Color.red)
            //                    .frame(width: 20, height: 20)
                        }
                    }
                }
            }
        }
        
//        ProgressBar(strokeWidth: 15, progress: CGFloat(1.5), color: .red)
//            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = PersistenceController().container.viewContext
        
        let habit = HabitItem(context: moc)
        habit.id = UUID()
        habit.habitName = "PreviewTest"
        habit.iconName = iconSections.randomElement()!.iconArray.randomElement()!
        habit.resetIntervalEnum = .daily
        habit.amountToDo = 4
        habit.iconColorIndex = Int16(iconColors.firstIndex(of: iconColors.randomElement()!)!)
        
        return ContentView()
            .environment(\.managedObjectContext, moc)
    }
}
