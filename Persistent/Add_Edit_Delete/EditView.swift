//
//  EditView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 25.05.21.
//

import SwiftUI
import CoreData
import UserNotifications

struct EditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let accentColor: Color
    
    let habit: HabitItem
    
    init(habit: HabitItem, accentColor: Color) {
        self.habit = habit
        
        self._name = State(initialValue: habit.habitName)
        self._description = State(initialValue: habit.habitDescription ?? "")
        self._amountToDo = State(initialValue: habit.amountToDo)
        self._intervalChoice = State(initialValue: habit.resetIntervalEnum.getString())
        self._colorSelection = State(initialValue: Int(habit.iconColorIndex))
        self._iconChoice = State(initialValue: habit.iconName ?? "None")
        
        self.accentColor = accentColor
        
        var selection = Set<UUID>()
        
        for tag in habit.wrappedTags {
            selection.insert(tag.wrappedId)
        }
        
        self._tagSelection = State(wrappedValue: selection)
    }
    
    @State var name = ""
    @State var description = ""
    @State var amountToDo: Int16 = 1
    @State var intervalChoice = "Day"
    @State private var colorSelection: Int = 0
    @State private var iconChoice: String = "Walking"
    
    let durationChoice = ["Day", "Week", "Month"]
    
    @State private var notificationEnabled: Bool = false
    @State private var notificationAmount: Int = 1
    @State private var notificationDates: [Date] = [Date()]
    @State private var weekdaySelection: Int = 0
    
    @State private var tagSelection: Set<UUID>
    
    func habitAddedVibration() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    let rows = [
            GridItem(.fixed(50), spacing: 10),
            GridItem(.fixed(50))
        ]
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Name & description")) {
                        TextField("Name", text: $name)
                        
                        TextField("Description", text: $description)
                    }
                    
                    Section(header: Text("How often?")) {
                        Picker("Tag oder Woche?", selection: $intervalChoice) {
                            ForEach(durationChoice, id: \.self) { choice in
                                Text(choice)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        Stepper(String(amountToDo), value: $amountToDo, in: 1...10)
                    }
                    
                    Section(header: Text("Symbol & Color")) {
                        NavigationLink(destination: ChooseIconView(iconChoice: $iconChoice)) {
                            ZStack(alignment: .leading) {
                                Image(iconChoice)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 50)
                                    .padding(.vertical, 5)
                                    .foregroundColor(iconColors[colorSelection])
                            }
                        }
                        
                        ScrollView(.horizontal) {
                            LazyHGrid(rows: rows, alignment: .center, spacing: 10) {
                                ForEach(0..<iconColors.count, id: \.self) { index in
                                    ZStack {
                                        Circle()
                                            .scaledToFit()
                                            .foregroundColor(iconColors[index])
                                            .shadow(color: Color.primary.opacity(0.4) ,radius: colorSelection == index ? 4 : 0)
                                        
//                                        if colorSelection == index {
//                                            RoundedRectangle(cornerRadius: 10)
//                                                .strokeBorder(Color.primary.opacity(0.15) ,lineWidth: 4)
//                                                .blur(radius: 3)
//                                        }
                                    }
                                    .scaleEffect(colorSelection == index ? 1.1 : 1)
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            colorSelection = index
                                        }
                                    }
                                }
                            }
                            .padding()
                        }
                        .listRowInsets(EdgeInsets())
                    }
                    
                    Section(header: Text("Tags")) {
                        //TagFormSection(selection: $tagSelection)
                        NavigationLink("Tags", destination: AlternativeTagSection(selectedTags: $tagSelection))
                    }
                    
                    Section(header: Text("Notifications")) {
                        VStack {
                            Toggle("Enable Notification", isOn: $notificationEnabled)
                            
                            if notificationEnabled {
                                Divider()
                                
                                Stepper("How many Notifications?", onIncrement: {
                                    self.notificationDates.append(Date())
                                    self.notificationAmount += 1
                                }, onDecrement: {
                                    self.notificationAmount -= 1
                                    if notificationAmount < 1 {
                                        self.notificationAmount += 1
                                        
                                        return
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                        self.notificationDates.removeLast()
                                    }
                                })
                                
                                Divider()
                                
                                ForEach(1...notificationAmount, id: \.self) { index in
                                    DatePicker("Nr. \(index)", selection: $notificationDates[index - 1], in: Date()...)
                                    
                                    ChooseWeekView(selection: $weekdaySelection)
                                        .onChange(of: weekdaySelection, perform: { value in
                                            let component = Calendar.current.component(.weekday, from: notificationDates[index - 1])

                                            let toAdd = value - component

                                            notificationDates[index - 1] = Calendar.current.date(byAdding: .weekday, value: toAdd, to: notificationDates[index - 1]) ?? notificationDates[index - 1]

                                            print(notificationDates[index - 1])
                                        })
                                        .onAppear {
                                            let component = Calendar.current.component(.weekday, from: Date())
                                            weekdaySelection = component - Calendar.current.firstWeekday
                                            print(component)
                                        }
                                }
                            }
                        }
                    }
                    
                    Button("Save Changes") {
                        habit.habitName = self.name
                        if description.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                            habit.habitDescription = self.description
                        }
                        habit.amountToDo = self.amountToDo
                        
                        switch intervalChoice {
                        case "Day":
                            habit.resetIntervalEnum = .daily
                        case "Week":
                            habit.resetIntervalEnum = .weekly
                        case "Month":
                            habit.resetIntervalEnum = .monthly
                        default:
                            habit.resetIntervalEnum = .daily
                        }
                        
                        habit.iconName = iconChoice
                        
                        print(iconChoice)
                        
                        habit.iconColorIndex = Int16(colorSelection)
                        
                        let tags = try? viewContext.fetch(NSFetchRequest<HabitTag>(entityName: "HabitTag"))
                        if let tags = tags {
                            let chosenTags = tags.filter { tagSelection.contains($0.wrappedId) }
                            for tag in chosenTags {
                                print(tag)
                            }
                            
                            habit.tags = NSSet(array: chosenTags)
                            
                        }
                        
                        editNotifications()
                        
                        habitAddedVibration()
                        
                        presentationMode.wrappedValue.dismiss()
                        
                        do {
                            try viewContext.save()
                        } catch {
                            let nsError = error as NSError
                            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationBarTitle("Edit Habit")
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .font(.title2.bold())
                    Spacer()
                }
                .frame(width: 50)
            }
            .contentShape(Rectangle()))
        }
        .accentColor(accentColor)
        .onAppear {
            loadNotifications()
        }
    }
    
    func loadNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        var dates: [Date] = []
        var count = 0
        var enabled: Bool = false
        
        notificationCenter.getPendingNotificationRequests { requests in
            var identifiers = [String]()
            
            for request in requests {
                if request.identifier.contains(habit.id.uuidString) {
                    identifiers.append(request.identifier)
                    
                    if let dateRequest = request.trigger as? UNCalendarNotificationTrigger {
                        
                        let todayComponents = Calendar.current.dateComponents([.year, .weekOfYear], from: Date())
                        
                        var components = dateRequest.dateComponents
                        components.year = todayComponents.year
                        components.weekOfYear = todayComponents.weekOfYear
                        
                        if let date = Calendar.current.date(from: components) {
                            dates.append(date)
                            count += 1
                        }
                    }
                }
            }
            
            count = max(1, count)
            
            if dates.isEmpty {
                dates = [Date()]
                enabled = false
            } else {
                enabled = true
            }
            
            notificationDates = dates
            notificationEnabled = enabled
            notificationAmount = count
        }
    }
    
    func editNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getPendingNotificationRequests { requests in
            var identifiers = [String]()
            
            for request in requests {
                if request.identifier.contains(habit.id.uuidString) {
                    identifiers.append(request.identifier)
                }
            }
            
            notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        }
            
        if notificationEnabled {
            let content = UNMutableNotificationContent()
            content.title = name
            content.body = "Keep your habit in mind!"

            for date in notificationDates {
                let components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: date)

                // Create the trigger as a repeating event.
                let trigger = UNCalendarNotificationTrigger(
                         dateMatching: components, repeats: true)

                let uuidString = habit.id.uuidString + UUID().uuidString

                let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

                let notificationCenter = UNUserNotificationCenter.current()

                notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        print(error)
                    } else if granted {
                        notificationCenter.add(request) { error in
                            if error != nil {

                            } else {
                                print("worked")
                            }
                        }
                    }
                }
            }
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    static var previews: some View {
        var testHabit: HabitItem {
            let testItem: HabitItem = HabitItem(context: moc)
            testItem.habitName = "Test"
            testItem.amountToDo = 3
            testItem.resetIntervalEnum = .monthly
            testItem.iconName = "Walking"
            testItem.iconColorIndex = 0
            
            let anotherNewItem = HabitCompletionDate(context: moc)
            anotherNewItem.date = Date()
            
            let secondNewItem = HabitCompletionDate(context: moc)
            secondNewItem.date = Date()
            testItem.date = NSSet(array: [anotherNewItem, secondNewItem])
            
            return testItem
        }
        return EditView(habit: testHabit, accentColor: Color.accentColor)
    }
}
