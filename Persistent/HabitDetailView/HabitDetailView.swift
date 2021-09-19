//
//  NewHabitDetailView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 14.05.21.
//

import SwiftUI
import CoreData



struct HabitDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var userSettings: UserSettings
    
    init(habit: HabitItem) {
        self.habit = habit
        
        switch habit.resetIntervalEnum {
        case .daily:
            habitIntervalString = "day"
        case .weekly:
            habitIntervalString = "week"
        case .monthly:
            habitIntervalString = "month"
        }
        
        self._viewModel = StateObject(wrappedValue: HabitDetailViewModel(habit: habit))
    }
    
    @StateObject private var viewModel: HabitDetailViewModel
    
    var habitIntervalString: String
    
    
    @ObservedObject var habit: HabitItem
    
    
//    func getDates() -> Int {
//        let currentDate = Date()
//        let firstDate = Date(timeIntervalSince1970: TimeInterval(0))
//
//        let components = Calendar.current.dateComponents([.day], from: firstDate, to: currentDate)
//
//        return components.day!
//    }
//
//    func changeDate(value: Int) {
//        withAnimation(.easeInOut) {
//            viewModel.chosenDateNumber = value
//            var component: DateComponents = DateComponents()
//            component.day = -value
//            viewModel.shownDate = Calendar.current.date(byAdding: component, to: Date()) ?? Date()
//        }
//    }
    
    var habitCircle: some View {
        ZStack {
            NewProgressBar(strokeWidth: 30, progress: viewModel.progress(), color: habit.iconColor, shadowRadius: 5)
                .aspectRatio(contentMode: .fit)
                .padding(25)
                .drawingGroup()
            
            HStack {
                Button(action: viewModel.removeFromHabit) {
                    Image(systemName: "minus.circle.fill")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                }
                
                VStack {
                    Text("\(viewModel.habit.relevantCount(viewModel.shownDate))/\(habit.amountToDo)")
                        .font(.system(size: 40, weight: .black, design: .monospaced))
                        .padding(.horizontal, 10)
                    Text("for this \(habitIntervalString)")
                        .font(.headline.weight(.light))
                }
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.15)) {
                        viewModel.multipleAddShown = true
                    }
                }
                
                Button(action: viewModel.addToHabit) {
                    Image(systemName: "plus.circle.fill")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 40)
                }
            }
        }
        .padding(.top)
        .padding(.horizontal, 25)
    }
    
    var multipleAdd: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(Color(UIColor.systemGray6))
                .shadow(color: .black.opacity(0.3), radius: 8)
            
            VStack {
                Picker("Add or Remove?", selection: $viewModel.multipleAddSelection) {
                    Text("Add").tag(MultipleAddEnum.add)
                    Text("Remove").tag(MultipleAddEnum.remove)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Text("How much?")
                    .font(.headline)
                
                ZStack(alignment: .trailing) {
                    TextField("Enter a number", text: $viewModel.multipleAddField, onCommit: {
                        
                    })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    
                    Button {
                        validate()
                    } label: {
                        Image(systemName: "checkmark")
                            .imageScale(.medium)
                            .padding()
                    }
                }
            }
            .padding(.horizontal)
        }
        .aspectRatio(2, contentMode: .fit)
        .padding(.horizontal, 30)
        .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.15)))
        .animation(.easeInOut)
    }
    
//    @State private var multipleAddSelection = MultipleAddEnum.add
//    @State private var multipleAddField = ""
//    @State private var multipleAddShown = false
    
    func validate() {
        if let multipleAddInt = Int(viewModel.multipleAddField) {
            switch viewModel.multipleAddSelection {
            case .add:
                for _ in 0 ..< multipleAddInt {
                    withAnimation(.easeInOut(duration: 2 - (2 - 0.15) * Double(pow(Float(1 - 0.075), Float(multipleAddInt))))) {
                        let newhabit = HabitCompletionDate(context: viewContext)
                        newhabit.date = viewModel.shownDate
                        newhabit.item = habit
                        
                        do {
                            try viewContext.save()
                            viewModel.selectionChanged()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                }
            case .remove:
                withAnimation(.easeInOut(duration: 2 - (2 - 0.15) * Double(pow(Float(1 - 0.075), Float(multipleAddInt))))) {
                    for _ in 0 ..< multipleAddInt {
                        if let habitObject = habit.dateArray.last(where: { Calendar.current.isDate($0.date!, equalTo: viewModel.shownDate, toGranularity: .day) }) {
                            viewContext.delete(habitObject as NSManagedObject)
                            viewModel.selectionChanged()
                        } else {
                            viewModel.errorVibration()
                        }
                        
                        do {
                            try viewContext.save()
                            
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                    
                }
            }
            viewModel.multipleAddField = ""
            viewModel.multipleAddShown = false
        } else {
            viewModel.errorVibration()
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                if habit.habitDescription != nil {
                    HStack {
                        Text(habit.habitDescription!)
                            .padding(20)
                        Spacer()
                    }
                }
                
//                HStack {
//                    ForEach(habit.wrappedTags, id: \.id) { tag in
//                        Text(tag.wrappedName)
//                    }
//                }
                
                habitCircle
                    .frame(minWidth: 0, maxWidth: .infinity)
                
                Spacer()
                
                Image(systemName: "calendar.circle.fill")
                    .font(.system(size: 50))
                    .padding()
                    .onTapGesture {
                        viewModel.calendarSheet = true
                    }
                    .foregroundColor(.accentColor)
            
            }
            .navigationBarTitle(habit.habitName, displayMode: .large)
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction) {
                    Menu() {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                viewModel.deleteActionSheet = true
                            }
                            
                        }) {
                            Text("Delete")
                                .foregroundColor(.red)
                        }
                        .foregroundColor(.red)
                        Button(action: {
                            viewModel.editSheet = true
                        }) {
                            Text("Edit")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            //.font(.title2.weight(.semibold))
                    }
                    .frame(height: 25)
                }
            })
            .sheet(isPresented: $viewModel.editSheet) {
                EditView(habit: habit, accentColor: userSettings.accentColor)
                    .environment(\.managedObjectContext, self.viewContext)
            }
            .sheet(isPresented: $viewModel.calendarSheet) {
                CalendarPagerView(habit: habit, date: $viewModel.shownDate, toggle: $viewModel.calendarSheet)
                    .padding(.top, 30)
            }
            .alert(isPresented: $viewModel.deleteActionSheet) {
                Alert(title: Text("Do you really want to delete this habit?"), primaryButton: .destructive(Text("Delete")) {
                    let request: NSFetchRequest<HabitItem> = HabitItem.fetchRequest()
                    request.fetchLimit = 1
                    request.predicate = NSPredicate(format: "%@ == id", habit.id as CVarArg)
                    do {
                        let habits = try viewContext.fetch(request)
                        print(habits)
                        for object in habits {
                            viewContext.delete(object)
                        }
                        
                        try viewContext.save()
                    } catch {
                        fatalError()
                    }
                }, secondaryButton: .cancel())
            }
            .zIndex(1)
            .blur(radius: viewModel.multipleAddShown ? 10 : 0)
            .contentShape(Rectangle())
            .onTapGesture {
                if viewModel.multipleAddShown {
                    withAnimation(.easeOut(duration: 0.15)) {
                        viewModel.multipleAddShown = false
                    }
                }
            }
            
            if viewModel.multipleAddShown {
                multipleAdd
                    .zIndex(2)
                    .padding(.top, 50)
            }
            
        }
        .ignoresSafeArea(.keyboard)
        
    }
}

struct ScrollCalendarDateView: View {
    let dateNumber: Int
    
    func getSpecificDate(value: Int, format: String) -> String {
        let currentDate = Date()
        let specificDate = Calendar.current.date(byAdding: .day, value: -value, to: currentDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: specificDate!)
    }
    
    var body: some View {
        VStack {
            Text(getSpecificDate(value: dateNumber, format: "dd"))
                .font(.headline)
            Text(getSpecificDate(value: dateNumber, format: "MMM"))
                .font(.body).fontWeight(.light)
        }
        .padding(5)
        .background(Color(red: 236 / 255, green: 47 / 255, blue: 75 / 255))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct NewHabitDetailView_Previews: PreviewProvider {
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
        return NavigationView {HabitDetailView(habit: testHabit)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }.previewDevice("iPhone 12")
    }
}
