//
//  AppSidebarNavigation.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 23.09.21.
//

import SwiftUI
import CoreData

enum NavigationItem: Hashable {
    case allHabits
    case dailyHabits
    case weeklyHabits
    case monthlyHabits
    
    case tag(_ id: UUID)
}

//struct Test: View {
//    #if os(iOS)
//    @Environment(\.horizontalSizeClass) var horizontalSizeClass
//    #endif
//    
//    @Environment(\.purchaseInfo) var purchaseInfo
//    @Environment(\.colorScheme) var colorScheme
////    @Environment(\.persistenceController) var persistenceController
//    
//    @EnvironmentObject private var userSettings: UserSettings
//    @EnvironmentObject private var appViewModel: AppViewModel
//    
//    @State private var selection: NavigationItem? = .allHabits
//    
//    @State var isExpanded: Bool = false
//    
//    @State var settingsSheet: Bool = false
//    
//    @FetchRequest(entity: HabitTag.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HabitTag.name, ascending: true)]) var tags: FetchedResults<HabitTag>
//    
//    @StateObject var viewModel: ListViewModel = .init()
//    
//    var body: some View {
//        NavigationView {
//            List {
//                Text("Habits")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                
//                NavigationLink(tag: NavigationItem.allHabits, selection: $selection) {
//                    ListView()
//                } label: {
//                    Label("All habits", systemImage: "checkmark.circle")
//                }
//                
//                DisclosureGroup(isExpanded: $isExpanded) {
//                    NavigationLink(tag: NavigationItem.dailyHabits, selection: $selection) {
//                        ListView(.daily)
//                    } label: {
//                        Label("Daily habits", systemImage: "clock.badge.checkmark")
//                    }
//                    
//                    NavigationLink(tag: NavigationItem.weeklyHabits, selection: $selection) {
//                        ListView(.weekly)
//                    } label: {
//                        Label("Weekly habits", systemImage: "clock.badge.checkmark")
//                    }
//                    
//                    NavigationLink(tag: NavigationItem.monthlyHabits, selection: $selection) {
//                        ListView(.monthly)
//                    } label: {
//                        Label("Monthly habits", systemImage: "clock.badge.checkmark")
//                    }
//                } label: {
//                    Label("Filter by interval", systemImage: "clock.badge.checkmark")
//                }
//                
//                //------
//                
//                Text("Tags")
//                    .font(.title2)
//                    .fontWeight(.bold)
//                
//                ForEach(tags) { tag in
//                    NavigationLink(tag: NavigationItem.tag(tag.wrappedId), selection: $selection) {
//                        ListView(.tag(tag))
//                    } label: {
//                        Label(tag.wrappedName, systemImage: "tag")
//                    }
//                }
//            }
//            .listStyle(.sidebar)
//            #if os(iOS)
//            .navigationTitle("Persistent")
//            .sheet(isPresented: $settingsSheet) {
//                SettingsView()
//                    .accentColor(userSettings.accentColor)
//                    .environmentObject(userSettings)
//                    .environmentObject(appViewModel)
//                    .environment(\.horizontalSizeClass, horizontalSizeClass)
//                    .environment(\.purchaseInfo, purchaseInfo)
//                    .preferredColorScheme(colorScheme)
//            }
//            .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    Button {
//                        settingsSheet = true
//                    } label: {
//                        Label("Settings", systemImage: "gear")
//                    }
//                }
//            }
//            #endif
//            
//            Text("Select a category")
//                .foregroundStyle(.secondary)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background()
//                .ignoresSafeArea()
//            
//            Text("Select a habit")
//                .foregroundStyle(.secondary)
//                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .background()
//                .ignoresSafeArea()
//        }
//        .navigationViewStyle(.columns)
//        
//    }
//}

//struct AppSidebarNavigationListSection: Hashable, Identifiable {
//    let name: String
//    let listFilters: [AppSidebarNavigationListItem]
//    let id = UUID()
//}

struct AppSidebarNavigation: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif

    @Environment(\.purchaseInfo) var purchaseInfo
    @Environment(\.colorScheme) var colorScheme
    //    @Environment(\.persistenceController) var persistenceController

    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject private var storeManager: StoreManager

    @State private var selection: NavigationItem? = .allHabits
    @State private var filter: ListFilterSelectionEnum = .all

    @State var isExpanded: Bool = false

    @State var settingsSheet: Bool = false
    
    @State private var shownHabit: HabitItem?
    @State private var habitToEdit: HabitItem? = nil

    @StateObject var viewModel: ListViewModel = .init()
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .all
    
    @State private var singleSelection: ListFilterSelectionEnum?
    
    struct AppSidebarNavigationListItem: Hashable, Identifiable {
        let name: String
        let systemName: String
        let listFilter: ListFilterSelectionEnum
        let id = UUID()
    }


    struct AppSidebarNavigationListSection: Identifiable {
        let name: String
        let items: [AppSidebarNavigationListItem]
        let id = UUID()
    }

    
    init(tags: [HabitTag]) {
        self.sidebarSections = [
            .init(name: "Habits", items: [
                .init(name: "All Habits", systemName: "checkmark.circle", listFilter: .all),
                .init(name: "Daily Habits", systemName: "clock.badge.checkmark", listFilter: .daily),
                .init(name: "Weekly Habits", systemName: "clock.badge.checkmark", listFilter: .weekly),
                .init(name: "Monthly Habits", systemName: "clock.badge.checkmark", listFilter: .monthly)
            ]),
            .init(name: "Tags", items:
                tags.map {
                    AppSidebarNavigationListItem(name: $0.wrappedName, systemName: "tag", listFilter: .tag($0))
                }
             )
        ]
    }

    private let sidebarSections: [AppSidebarNavigationListSection]
        
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List(selection: $singleSelection) {
                ForEach(sidebarSections) { section in
                    Section(header: Text(section.name)) {
                        ForEach(section.items) { item in
                            NavigationLink(value: item.listFilter) {
                                Label(item.name, systemImage: item.systemName)
                            }
                        }
                    }
                }
            }
            .onChange(of: singleSelection ?? .all) { selection in
                filter = selection
            }
            .listStyle(.sidebar)
            .buttonStyle(.plain)
            #if os(iOS)
            .navigationTitle("Persistent")
            .sheet(isPresented: $settingsSheet) {
                SettingsView()
                    .accentColor(userSettings.accentColor)
                    .environmentObject(userSettings)
                    .environmentObject(appViewModel)
                    .environmentObject(storeManager)
                    .environment(\.horizontalSizeClass, horizontalSizeClass)
                    .environment(\.purchaseInfo, purchaseInfo)
                    .preferredColorScheme(colorScheme)
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
        } content: {
            SplitViewListView(filter, shownHabit: $shownHabit, splitViewVisibility: $columnVisibility)
        } detail: {
            VStack {
                if let shownHabit {
                    HabitDetailView(habit: shownHabit, habitToEdit: $habitToEdit)
                }
            }
        }
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
        AppSidebarNavigation(tags: [])
    }
}
