//
//  SettingsView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 24.05.21.
//

import SwiftUI
import WidgetKit
import StoreKit

struct SettingsView: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var storeManager: StoreManager
    
    @State var syncEnabled: Bool
    
    @State var premiumSheet: Bool = false
    
    init() {
        self._syncEnabled = State(wrappedValue: UserDefaults.standard.bool(forKey: "syncEnabled"))
    }
    
    var product: Product? {
        return storeManager.products.first(where: { $0.id == "quaritsch.bennnett.Persistent.premium.single" })
    }
    
    var body: some View {
        NavigationView {
            List {
                Button {
                    premiumSheet = true
                } label: {
                    HStack {
                        Spacer()
                        
                        VStack(spacing: 10) {
                            Text("Persistent Premium")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.accentColor)
                            
                            Text("Buy Premium for \(product?.displayPrice ?? "unknown price")")
                                .fontWeight(.semibold)
                        }
                        
                        Spacer()
                    }
                    .padding(10)
                }
                .buttonStyle(.plain)
                
                Section("Interface Design") {
                    NavigationLink(destination: AccentColorSetting()) {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(userSettings.accentColor)
                            
                            Text("Accent Color")
                        }
                    }
                    
                    NavigationLink(destination: ChangeAppIconView()) {
                        HStack {
                            Image(systemName: "app.fill")
                                .foregroundColor(userSettings.accentColor)
                            
                            Text("App Icon")
                        }
                    }
                }
                
                Section("Habits") {
                    NavigationLink(destination: DeletedHabits()) {
                        HStack {
                            Image(systemName: "trash.fill")
                                .foregroundColor(userSettings.accentColor)
                            
                            Text("Deleted Habits")
                        }
                    }
                }
                
                Section("Sync") {
                    HStack {
                        Image(systemName: "icloud.fill")
                            .foregroundColor(userSettings.accentColor)
                        
                        Toggle("iCloud Sync", isOn: $syncEnabled)
                            .onChange(of: syncEnabled) { value in
                                UserDefaults.standard.set(value, forKey: "syncEnabled")
                            }
                    }
                }
                
                Section("About") {
                    NavigationLink(destination: AboutPersistentView()) {
                        Label("Thanks to", systemImage: "hand.thumbsup.fill")
                    }
                }
                
                //NavigationLink("calendar", destination: CalendarPageViewController(toggle: .constant(true), habitDate: .constant(Date()), date: Date(), habit: previewTestHabit))
                
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
                #if os(iOS)
                Button("Delete all notifications") {
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                }
                #endif
                
//                NavigationLink(destination: HabitCompletionGraph()) {
//                    Text("Graph")
//                }
//
//                NavigationLink("Tags", destination: AlternativeTagSection(selectedTags: .constant(Set<UUID>())))
            }
            #if os(iOS)
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Settings")
            #endif
        }
        .sheet(isPresented: $premiumSheet) {
            #if os(iOS)
            BuyPremiumView()
                .accentColor(userSettings.accentColor)
                .environment(\.horizontalSizeClass, horizontalSizeClass)
            #endif
        }
    }
}

struct DeletedHabits: View {
    #if os(iOS)
    @Environment(\.editMode) private var editMode
    #endif
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: HabitItem.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.habitName, ascending: true)]) var items: FetchedResults<HabitItem>
    
    @State private var selection = Set<UUID>()
    
    var body: some View {
        List(selection: $selection) {
            ForEach(items, id: \.id) { habit in
                if habit.habitDeleted {
                    ListCellView(habit: habit, viewModel: ListViewModel())
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                withAnimation {
                                    habit.habitDeleted = false
                                    
                                    do {
                                        try viewContext.save()
                                    } catch {
                                        let nsError = error as NSError
                                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                    }
                                }
                            } label: {
                                Label("Undo Delete", systemImage: "trash.slash")
                            }
                            .tint(.green)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                withAnimation {
                                    habit.deleteHabitPermanently()
                                    
                                    do {
                                        try viewContext.save()
                                    } catch {
                                        let nsError = error as NSError
                                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                    }
                                }
                            } label: {
                                Label("Final Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .onDelete(perform: deleteHabitWithOffset)
            #if os(iOS)
            .onChange(of: editMode?.wrappedValue) { _ in
                selection = []
            }
            #endif
        }
        #if os(iOS)
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Deleted Habits")
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if editMode?.wrappedValue == .active {
                    Button {
                        withAnimation {
                            for habit in items where selection.contains(habit.id) {
                                habit.deleteHabitPermanently()
                            }
                            
                            do {
                                try viewContext.save()
                            } catch {
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                    
                    Button {
                        withAnimation {
                            for habit in items where selection.contains(habit.id) {
                                habit.habitDeleted = false
                            }
                            
                            do {
                                try viewContext.save()
                            } catch {
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
                        }
                    } label: {
                        Image(systemName: "trash.slash")
                    }
                }
                
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
        #if os(iOS)
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Accent Color")
        #endif
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

