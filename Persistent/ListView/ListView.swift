//
//  ContentView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 14.05.21.
//

import SwiftUI
import CoreData

struct ListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.colorScheme) var colorScheme
    
    @Environment(\.editMode) var editMode

    /// Init with optional Predicate. When predicate = nil, no predicate will be used.
    
    init(predicate: [NSPredicate]?) {
        if let predicate = predicate {
            let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicate)
            
            _items = FetchRequest(
                sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.habitName, ascending: true)],
                predicate: combinedPredicate,
                animation: .default)
        } else {
            _items = FetchRequest(
                sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.habitName, ascending: true)],
                animation: .default)
        }
    }
    
    init() {
        _items = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.habitName, ascending: true)],
            animation: .default)
    }
    
    @FetchRequest private var items: FetchedResults<HabitItem>

    func deleteHabitWithOffset(at offsets: IndexSet) {
        for index in offsets {
            let habit = items[index]
            habit.deleteHabit()
            
            do {
                try viewContext.save()
            } catch {
                fatalError()
            }
        }
    }
    
    @State private var selection = Set<UUID>()
    @State private var testBool = false
    
    var body: some View {
        List(selection: $selection) {
            ForEach(items, id: \.id) { item in
                if !item.habitDeleted {
                    Section {
                        NavigationLink(destination: HabitDetailView(habit: item)) {
                            HStack {
                                if item.iconName != nil {
                                    Image(item.iconName!)
                                        .resizable()
                                        .foregroundColor(item.iconColor)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(height: 40)
                                        //.padding(.trailing, 5)
                                }

                                Text(item.habitName)
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.4)
                                    .padding(.trailing, 5)

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
                            .animation(.easeOut(duration: 0.25))
                        }
                    }
                }
            }
            .onDelete(perform: deleteHabitWithOffset)
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("All Habits")
        .toolbar {
            #if os(iOS)
            
            ToolbarItem(placement: .navigationBarTrailing) {
                deleteButton
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            
            #endif
        }
    }
    
    var deleteButton: some View {
        VStack {
            if editMode?.wrappedValue == .active {
                Button {
                    print(selection)
                    
                    for habit in items where selection.contains(habit.id) {
                        habit.deleteHabit()
                    }
                    
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                } label: {
                    Image(systemName: "trash.fill")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .font(.title2.weight(.semibold))
                }
            }
        }
    }
}

struct CustomListCell: View {
    @ObservedObject var item: HabitItem
    
    var body: some View {
        HStack {
            Text(item.habitName)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            Spacer()
            ZStack {
                Text("\(relevantCount(habit: item))/\(item.amountToDo)")
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                CircleProgressBar(progress: CGFloat(relevantCount(habit: item)) / CGFloat(item.amountToDo), strokeWidth: 7)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
            }
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
}

fileprivate func relevantCount(habit: HabitItem) -> Int {
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



struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ListView()
                .previewDevice("iPhone 12")
        }
            //.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
