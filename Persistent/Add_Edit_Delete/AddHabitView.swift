//
//  AddHabitView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 14.05.21.
//

import SwiftUI
import CoreData

let iconChoices = ["man", "woman", "walk", "body", "person", "people", "american-football", "barbell", "baseball", "tennisball", "basketball", "bowling-ball", "fitness", "football", "footsteps", "airplane", "alarm", "aperture", "archive", "at-circle", "bag", "balloon", "ban", "bandage", "bar-chart", "barcode", "basket", "bed", "beer", "bicycle", "boat", "book", "bookmark", "briefcase", "brush", "bug", "build", "bulb", "bus", "business", "cafe", "calculator", "calendar", "call", "camera", "car-sport", "car", "card", "cart", "cash", "chatbox", "checkmark-circle", "clipboard", "cloud", "cloudy", "code-slash", "cog", "color-filter", "color-palette", "color-wand", "create", "crop", "cut", "desktop", "dice", "disc", "document", "download", "ear", "earth", "extension-puzzle", "eye", "eyedrop", "fast-food", "file-tray", "film", "finger-print", "fish", "flag", "flame", "flash", "flask", "flower", "folder", "funnel", "game-controller", "gift", "git-branch", "glasses", "golf", "hammer", "hand-left", "happy", "hardware-chip", "headset", "heart", "hourglass", "ice-cream", "id-card", "image", "journal", "key", "language", "laptop", "layers", "leaf", "library", "link", "list", "location", "lock-closed", "magnet", "mail", "map", "medical", "medkit", "mic", "moon", "musical-notes", "navigate", "newspaper", "notifications", "nuclear", "nutrition", "partly-sunny", "paw", "pencil", "pie-chart", "pint", "pizza", "planet", "play", "pricetag", "print", "qr-code", "radio", "rainy", "reader", "restaurant", "ribbon", "rocket", "rose", "sad", "save", "school", "server", "shield", "shirt", "skull", "snow", "sparkles", "storefront", "subway", "sunny", "telescope", "terminal", "text", "thermometer", "thumbs-down", "thumbs-up", "thunderstorm", "ticket", "time", "timer", "toggle", "trash", "tv", "umbrella", "videocam", "volume-high", "wallet", "watch", "wine"]

struct AddHabitView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    let accentColor: Color
    
    @State var name = ""
    @State var description = ""
    @State var timesPerDay = 3
    @State var intervalChoice = "Day"
    
    @State var tagSelection = Set<UUID>()
    
    let uuid = UUID()
    
    let durationChoice = ["Day", "Week", "Month"]
    
    @State private var iconChoice: String = "person"
    
    func habitAddedVibration() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    let rows = [
            GridItem(.fixed(50), spacing: 10),
            GridItem(.fixed(50))
        ]
    
    @State private var colorSelection: Int = 0
    
    @State private var notificationEnabled: Bool = false
    @State private var notificationAmount: Int = 1
    @State private var notificationDates: [Date] = [Date()]
    @State private var weekdaySelection: Int = 0
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Name & Description")) {
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
                        Stepper(String(timesPerDay), value: $timesPerDay, in: 1...10)
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
                                    }
                                    .scaleEffect(colorSelection == index ? 1.1 : 1)
                                    .onTapGesture {
                                        withAnimation(.easeOut(duration: 0.2)) {
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
                                    print(notificationAmount)
                                }, onDecrement: {
                                    self.notificationAmount -= 1
                                    if notificationAmount < 1 {
                                        self.notificationAmount += 1
                                        
                                        return
                                    }
                                    print(notificationAmount)
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                                        self.notificationDates.removeLast()
                                    }
                                })
                                
                                Divider()
                                
                                ForEach(1...notificationAmount, id: \.self) { index in
                                    DatePicker("Nr. \(index)", selection: $notificationDates[index - 1], in: Date()..., displayedComponents: [.hourAndMinute])
                                        //.datePickerStyle(GraphicalDatePickerStyle())
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
                    
                    addHabitButton
                }
                .listStyle(InsetGroupedListStyle())
            }
            .navigationBarTitle("Create a Habit")
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
    }
    
    var addHabitButton: some View {
        Button("Add your Habit") {
            let newhabit = HabitItem(context: viewContext)
            newhabit.id = uuid
            newhabit.habitName = name
            if description.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                newhabit.habitDescription = description
            }
            newhabit.amountToDo = Int16(timesPerDay)
            
            let habitInterval: ResetIntervals
            
            switch intervalChoice {
            case "Day":
                habitInterval = .daily
            case "Week":
                habitInterval = .weekly
            case "Month":
                habitInterval = .monthly
            default:
                habitInterval = .daily
            }
            
            newhabit.resetIntervalEnum = habitInterval
            
            newhabit.iconName = iconChoice
            
            newhabit.iconColorIndex = Int16(colorSelection)
            
            let tags = try? viewContext.fetch(NSFetchRequest<HabitTag>(entityName: "HabitTag"))
            if let tags = tags {
                let chosenTags = tags.filter { tagSelection.contains($0.wrappedId) }
                for tag in chosenTags {
                    print(tag)
                }
                
                newhabit.tags = NSSet(array: chosenTags)
                
            }
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            
            setNotification()
            
            habitAddedVibration()
            
            presentationMode.wrappedValue.dismiss()
        }
    }
    
    func setNotification() {
        if notificationEnabled {
            let content = UNMutableNotificationContent()
            content.title = name
            content.body = "Keep your habit in mind!"

            for date in notificationDates {
                let components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: date)

                // Create the trigger as a repeating event.
                let trigger = UNCalendarNotificationTrigger(
                         dateMatching: components, repeats: true)

                let uuidString = uuid.uuidString + UUID().uuidString

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

/// View for choosing Icons from a grid.
struct ChooseIconView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let columns = [GridItem(.adaptive(minimum: 60, maximum: 80))]
    
    @Binding var iconChoice: String
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                    ForEach(iconChoices, id: \.self) { icon in
                        ZStack {
//                            if iconChoice == icon {
//                                RoundedRectangle(cornerRadius: 15)
//                                    .foregroundColor(Color(UIColor.systemGray5))
//                            }
                            
                            ZStack {
                                Image(icon)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(8)
                                
                                Color.primary.blendMode(.sourceAtop)
                            }
                            .onTapGesture {
                                iconChoice = icon
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitView(accentColor: Color.accentColor)
            .previewDevice("iPhone 12")
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
