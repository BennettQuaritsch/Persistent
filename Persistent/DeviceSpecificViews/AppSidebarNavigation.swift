//
//  AppSidebarNavigation.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 23.09.21.
//

import SwiftUI

enum NavigationItem: Hashable {
    case allHabits
    case dailyHabits
    case weeklyHabits
    case monthlyHabits
    
    case tag(_ id: UUID)
}

struct AppSidebarNavigation: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    @EnvironmentObject private var userSettings: UserSettings
    
    @State private var selection: NavigationItem? = .allHabits
    
    @State var isExpanded: Bool = false
    
    @State var settingsSheet: Bool = false
    
    @FetchRequest(entity: HabitTag.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HabitTag.name, ascending: true)]) var tags: FetchedResults<HabitTag>
    
    func tagPredicate(_ tag: HabitTag) -> NSPredicate {
        return NSPredicate(format: "%@ IN tags", tag)
    }
    
    var dayPredicate: NSPredicate {
        return NSPredicate(format: "resetInterval == 'daily'")
    }
    
    var weekPredicate: NSPredicate {
        return NSPredicate(format: "resetInterval == 'weekly'")
    }
    
    var monthPredicate: NSPredicate {
        return NSPredicate(format: "resetInterval == 'monthly'")
    }
    
    @StateObject var viewModel: ListViewModel = .init()
    
    var body: some View {
        NavigationView {
            List {
                Text("Habits")
                    .font(.title2)
                    .fontWeight(.bold)
                
                NavigationLink(tag: NavigationItem.allHabits, selection: $selection) {
                    ListView(predicate: nil)
                } label: {
                    Label("All habits", systemImage: "checkmark.circle")
                }
                
                DisclosureGroup(isExpanded: $isExpanded) {
                    NavigationLink(tag: NavigationItem.dailyHabits, selection: $selection) {
                        ListView(predicate: [dayPredicate])
                    } label: {
                        Label("Daily habits", systemImage: "clock.badge.checkmark")
                    }
                    
                    NavigationLink(tag: NavigationItem.weeklyHabits, selection: $selection) {
                        ListView(predicate: [weekPredicate])
                    } label: {
                        Label("Weekly habits", systemImage: "clock.badge.checkmark")
                    }
                    
                    NavigationLink(tag: NavigationItem.monthlyHabits, selection: $selection) {
                        ListView(predicate: [monthPredicate])
                    } label: {
                        Label("Monthly habits", systemImage: "clock.badge.checkmark")
                    }
                } label: {
                    Label("Filter by interval", systemImage: "clock.badge.checkmark")
                }
                
                //------
                
                Text("Tags")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ForEach(tags) { tag in
                    NavigationLink(tag: NavigationItem.tag(tag.wrappedId), selection: $selection) {
                        ListView(predicate: [tagPredicate(tag)])
                    } label: {
                        Label(tag.wrappedName, systemImage: "tag")
                    }
                }
            }
            .listStyle(.sidebar)
            #if os(iOS)
            .navigationTitle("Persistent")
            .sheet(isPresented: $settingsSheet) {
                SettingsView()
                    .accentColor(userSettings.accentColor)
                    .environmentObject(userSettings)
                    .environment(\.horizontalSizeClass, horizontalSizeClass)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        settingsSheet = true
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
            #endif
            
            Text("Select a category")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background()
                .ignoresSafeArea()
            
            Text("Select a habit")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background()
                .ignoresSafeArea()
        }
        .navigationViewStyle(.columns)
        
    }
}

#if os(iOS)
extension UISplitViewController {
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.show(.primary)
    }
}
#endif

struct AppSidebarNavigation_Previews: PreviewProvider {
    static var previews: some View {
        AppSidebarNavigation()
    }
}
