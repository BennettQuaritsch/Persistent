//
//  SettingsView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 24.05.21.
//

import SwiftUI
import WidgetKit

struct SettingsView: View {
    @EnvironmentObject private var userSettings: UserSettings
    
    @State var syncEnabled: Bool
    
    init() {
        self._syncEnabled = State(wrappedValue: UserDefaults.standard.bool(forKey: "syncEnabled"))
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Interface Design")) {
                    NavigationLink(destination: AccentColorSetting()) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(userSettings.accentColor)
                            
                            Text("Accent Color")
                        }
                    }
                    
                    
                    HStack {
                        Image(systemName: "app.fill")
                            .foregroundColor(userSettings.accentColor)
                        
                        Text("App Icon")
                    }
                }
                
                Section(header: Text("Habits")) {
                    NavigationLink(destination: DeletedHabits()) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(userSettings.accentColor)
                            
                            Text("Deleted Habits")
                        }
                    }
                }
                
                Section(header: Text("Sync")) {
                    HStack {
                        Image(systemName: "icloud.fill")
                            .foregroundColor(userSettings.accentColor)
                        
                        Toggle("iCloud Sync", isOn: $syncEnabled)
                            .onChange(of: syncEnabled) { value in
                                UserDefaults.standard.set(value, forKey: "syncEnabled")
                            }
                    }
                }
                
                Section(header: Text("About")) {
                    NavigationLink(destination: AboutPersistentView()) {
                        Label("Thanks to", systemImage: "hand.thumbsup.fill")
                    }
                }
                
                
                #if DEBUG
                
                #endif
//                NavigationLink(destination: AlternativeListView()) {
//                    Text("Alternativer List View")
//                }
//
//
//                Button("Update Widgets") {
//                    WidgetCenter.shared.reloadAllTimelines()
//                }
//
//                Button("Delete all notifications") {
//                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//                }
//
//                NavigationLink("Tags", destination: AlternativeTagSection(selectedTags: .constant(Set<UUID>())))
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Settings")
        }
    }
}

struct DeletedHabits: View {
    @Environment(\.editMode) private var editMode
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: HabitItem.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.habitName, ascending: true)]) var items: FetchedResults<HabitItem>
    
    @State private var selection = Set<UUID>()
    
    var body: some View {
        List(selection: $selection) {
            ForEach(items, id: \.id) { habit in
                if habit.habitDeleted {
                    DeletedHabitListCell(habit: habit)
                }
            }
            .onDelete(perform: deleteHabitWithOffset)
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Deleted Habits")
        .toolbar {
            #if os(iOS)
            
            ToolbarItem(placement: .navigationBarTrailing) {
                deleteButton
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                undoDeleteButton
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
                
            }
            
            #endif
        }
    }
    
    func deleteHabitWithOffset(at offsets: IndexSet) {
        for index in offsets {
            let habit = items[index]
            habit.deleteHabitPermanently()
            
            do {
                try viewContext.save()
            } catch {
                fatalError()
            }
        }
    }
    
    var deleteButton: some View {
        VStack {
            if editMode?.wrappedValue == .active {
                Button {
                    print(selection)
                    
                    viewContext.perform {
                        
                    }
                    for habit in items where selection.contains(habit.id) {
                        habit.deleteHabitPermanently()
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
    
    var undoDeleteButton: some View {
        VStack {
            if editMode?.wrappedValue == .active {
                Button {
                    print(selection)
                    
                    for habit in items where selection.contains(habit.id) {
                        habit.habitDeleted = false
                    }
                    
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                } label: {
                    Image(systemName: "trash.slash.fill")
                        .resizable()
                        .aspectRatio(1, contentMode: .fit)
                        .font(.title2.weight(.semibold))
                }
            }
        }
    }
}

struct DeletedHabitListCell: View {
    var habit: HabitItem
    
    var body: some View {
        HStack {
            if habit.iconName != nil {
                ZStack {
                    Image(habit.iconName!)
                        .resizable()
                    
                    //iconColors[item.iconColorIndex].blendMode(.sourceAtop)
                    
                    habit.iconColor.blendMode(.sourceAtop)
                }
                .aspectRatio(contentMode: .fit)
                .frame(height: 40)
                    //.padding(.trailing, 5)
            }
            
            Text(habit.habitName)
                .font(.title)
                .fontWeight(.semibold)
            
            Spacer()
            
            ZStack {
                Text("\(relevantCount(habit: habit))/\(habit.amountToDo)")
                    .fontWeight(.bold)
                NewProgressBar(strokeWidth: 7, progress: habit.progress(), color: habit.iconColor)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 50)
            }
            .padding(.trailing)
            .padding(.vertical, 3)
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
}

struct AccentColorSetting: View {
    @EnvironmentObject private var settings: UserSettings
    @State var selection = 0
    
    var body: some View {
        List {
            Picker("Select your preffered Color", selection: $selection) {
                ForEach(0..<settings.colors.count) { index in
                    HStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(settings.colors[index].color)
                            .scaledToFit()
                            .frame(width: 30)
                            .padding(.trailing, 5)
                        
                        Text("\(settings.colors[index].name)")
                    }
                }
            }
            .pickerStyle(InlinePickerStyle())
            .onChange(of: selection, perform: { value in
                settings.accentColorIndex = value
            })
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Accent Color")
        .onAppear {
            selection = settings.accentColorIndex
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .previewDevice("iPhone 12")
            .environmentObject(UserSettings())
    }
}

