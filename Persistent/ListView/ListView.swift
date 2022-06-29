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
    @Environment(\.purchaseInfo) var purchaseInfo
    
    #if os(iOS)
    //@Environment(\.editMode) var editMode
    @State var editMode: EditMode = .inactive
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.parentSizeClass) var parentSizeClass
    #endif
    
    @State private var showSettings: Bool = false
    
    @State private var purchaseAlert = false
    
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var appViewModel: AppViewModel
    
    @State private var filterOption: ListFilterSelectionEnum
    
//    @SceneStorage
    
    @FetchRequest(entity: HabitTag.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HabitTag.name, ascending: true)]) var tags: FetchedResults<HabitTag>
    
    var predicate: NSPredicate? {
        switch filterOption {
        case .all:
            return nil
        case .daily:
            return NSPredicate(format: "resetInterval == 'daily'")
        case .weekly:
            return NSPredicate(format: "resetInterval == 'weekly'")
        case .monthly:
            return NSPredicate(format: "resetInterval == 'monthly'")
        case .tag(let habitTag):
            return NSPredicate(format: "%@ IN tags", habitTag)
        }
    }

    var habitLimitReached: Bool {
        return !purchaseInfo.wrappedValue && items.count >= 3
    }
    
    init(_ filter: ListFilterSelectionEnum = .all) {
        
        var tempPredicate: NSPredicate?
        
        switch filter {
        case .all:
            tempPredicate = nil
        case .daily:
            tempPredicate = NSPredicate(format: "resetInterval == 'daily'")
        case .weekly:
            tempPredicate = NSPredicate(format: "resetInterval == 'weekly'")
        case .monthly:
            tempPredicate = NSPredicate(format: "resetInterval == 'monthly'")
        case .tag(let habitTag):
            tempPredicate = NSPredicate(format: "%@ IN tags", habitTag)
        }
        
        _items = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.habitName, ascending: true)],
            predicate: tempPredicate,
            animation: .easeInOut)
        
        self._filterOption = State(initialValue: filter)
    }
    
    @FetchRequest private var items: FetchedResults<HabitItem>
    
    @StateObject var viewModel: ListViewModel = .init()
    
    var shownItems: [HabitItem] {
        var tempItems: [HabitItem] = []
        
        let adjustedDate: Date = Date().adjustedForNightOwl()

        switch viewModel.sortingOption {
        case .nameAscending:
            tempItems = items.sorted(by: { $0.habitName < $1.habitName })
        case .nameDescending:
            tempItems = items.sorted(by: { $0.habitName > $1.habitName })
        case .percentageDoneAscending:
            tempItems = items.sorted(by: { $0.progress(adjustedDate) < $1.progress(adjustedDate) })
        case .percentageDoneDescending:
            tempItems = items.sorted(by: { $0.progress(adjustedDate) > $1.progress(adjustedDate) })
        }
        
        if viewModel.searchText.isEmpty {
            //return items.map {$0}
            return tempItems
        } else {
            return items.filter { $0.habitName.contains(viewModel.searchText) }
        }
    }
    
    private var isEditing: Bool {
            editMode.isEditing
        }
    
    func backgroundColor(item: HabitItem) -> Color {
        if parentSizeClass == .compact {
            return Color("secondarySystemGroupedBackground")
        } else {
            if item.id == selectedID {
                return Color.accentColor
            } else {
                return Color("secondarySystemGroupedBackground")
            }
        }
    }
    
    @State private var selectedID: UUID?
    @SceneStorage("selectedHabit") private var selectedIDString: String?
    
    @SceneStorage("listViewFilterOption") private var filterOptionString: String = "All Habits"
    
    @State private var habitDeleteAlertActive: Bool = false
    @State private var habitToDelete: HabitItem?
    
    var body: some View {
        ScrollView {
            if !shownItems.isEmpty {
                VStack {
                    ForEach(shownItems, id: \.id) { item in
                        if !item.habitArchived {
                            NavigationLink(tag: item.id, selection: $selectedID, destination: {
                                HabitDetailView(habit: item, listViewModel: viewModel)
                                    .environmentObject(appViewModel)
                            }) {
                                ListCellView(habit: item, viewModel: viewModel)
                                    .habitDeleteAlert(isPresented: $habitDeleteAlertActive, habit: habitToDelete, context: viewContext)
                                    .contentShape(ContentShapeKinds.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .contextMenu {
                                        Button {
                                            withAnimation {
                                                item.deleteHabit()
                                            }
                                        } label: {
                                            Label("Archive", systemImage: "archivebox")
                                        }
                                        
                                        Button(role: .destructive) {
                                            withAnimation {
                                                habitToDelete = item
                                                habitDeleteAlertActive = true
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                    
                            }
                            .buttonStyle(.plain)
                            .padding(.top)
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 100)
                }
            } else {
                VStack {
                    Text("It's empty here ☹️")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding()
                        
                    Text("Press + to add a habit")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
        .background(Color("systemGroupedBackground"))
        .onChange(of: filterOption) { selection in
            items.nsPredicate = predicate
            
            filterOptionString = selection.codingID
        }
        .onAppear {
            if parentSizeClass == .compact {
                filterOption = ListFilterSelectionEnum(from: filterOptionString, context: viewContext)
            }
        }
        .onChange(of: selectedID) { id in
            selectedIDString = id?.uuidString
        }
        .onAppear {
            if parentSizeClass != .compact {
                if let selectedIDString = selectedIDString {
                    selectedID = UUID(uuidString: selectedIDString)
                }
            }
        }
        .tint(.accentColor)
        .overlay(
            HStack {
                if !userSettings.leftHandedInterface {
                    Spacer()
                }

                ZStack {
                    Circle()
                        .fill(habitLimitReached ? Color.gray : Color.accentColor)
                        .shadow(radius: 8)

                    Image(systemName: "plus")
                        .resizable()
                        .foregroundColor(Color("systemBackground"))
                        .frame(width: 25, height: 25)
                }
                .frame(width: 60, height: 60)
                .onTapGesture {
                    if habitLimitReached {
                        purchaseAlert = true
                        warningVibration()
                    } else {
                        viewModel.addSheetPresented = true
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 25, bottom: 25, trailing: 25))
                
                if userSettings.leftHandedInterface {
                    Spacer()
                }
            }
            , alignment: .bottom)
        //.listStyle(InsetGroupedListStyle())
        .searchable(text: $viewModel.searchText, prompt: "Search for a habit")
        #if os(iOS)
        .navigationTitle(filterOption.name)
        #endif
        .toolbar {
            #if os(iOS)
//            editAndDeleteButton
            
            ToolbarItemGroup(placement: .navigationBarLeading) {
                if parentSizeClass == .compact {
                    Button {
                        showSettings = true
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
                
                habitListMenu
            }
            #endif
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if habitLimitReached {
                        purchaseAlert = true
                        warningVibration()
                    } else {
                        viewModel.addSheetPresented = true
                    }
                } label: {
                    Label("Add habit", systemImage: "plus")
                        .labelStyle(.iconOnly)
                }
            }
        }
        .sheet(isPresented: $viewModel.addSheetPresented, content: {
            AddHabitView(accentColor: userSettings.accentColor)
                .accentColor(userSettings.accentColor)
            .environment(\.managedObjectContext, self.viewContext)
            .environment(\.purchaseInfo, purchaseInfo)
        })
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .accentColor(userSettings.accentColor)
                .environmentObject(userSettings)
                .environmentObject(appViewModel)
                .environment(\.horizontalSizeClass, horizontalSizeClass)
                .environment(\.purchaseInfo, purchaseInfo)
                .preferredColorScheme(colorScheme)
        }
        .environment(\.editMode, $editMode)
        .alert("Your have reached your limit of habits", isPresented: $purchaseAlert) {
            Button("OK", role: .cancel) {
                purchaseAlert = false
            }
        } message: {
            Text("Purchase Persistent Premium to add unlimited habits and to support me 😊")
        }
    }
    
    #if os(iOS)
    var editAndDeleteButton: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            if editMode == .active {
                Button {
                    for habit in items where viewModel.selection.contains(habit.id) {
                        habit.deleteHabit()
                    }

                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                } label: {
                    Image(systemName: "trash")
                }
            }
            
            EditButton()
        }
    }
    #endif
    
    func predicateButton(filter: ListFilterSelectionEnum, text: String, imageName: String? = nil) -> some View {
        Button {
            withAnimation(.easeInOut) {
                filterOption = filter
            }
        } label: {
            if let imageName = imageName {
                Label(text, systemImage: imageName)
            } else {
                Text(text)
            }
        }
    }
    
    var habitListMenu: some View {
        Menu() {
            Menu {
                Menu {
                    Button("Ascending") {
                        withAnimation {
                            viewModel.sortingOption = .nameAscending
                        }
                    }

                    Button("Descending") {
                        withAnimation {
                            viewModel.sortingOption = .nameDescending
                        }
                    }
                } label: {
                    Label("Name", systemImage: "abc")
                }
                
                Menu {
                    Button("Ascending") {
                        withAnimation {
                            viewModel.sortingOption = .percentageDoneAscending
                        }
                    }
                    
                    Button("Descending") {
                        withAnimation {
                            viewModel.sortingOption = .percentageDoneDescending
                        }
                    }
                } label: {
                    Label("Percentage Done", systemImage: "percent")
                }
            } label: {
                Label("Sorting", systemImage: "line.3.horizontal")
            }
            
            if parentSizeClass == .compact {
                predicateButton(filter: .all, text: "All Habits", imageName: "checkmark.circle")
                
                Menu {
                    predicateButton(filter: .daily, text: "Daily Habits")
                    
                    predicateButton(filter: .weekly, text: "Weekly Habits")
                    
                    predicateButton(filter: .monthly, text: "Monthly Habits")
                } label: {
                    Label("Intervals", systemImage: "timer")
                }
                
                Menu {
                    ForEach(tags) { tag in
                        predicateButton(filter: .tag(tag), text: tag.wrappedName)
                    }
                } label: {
                    Label("Tags", systemImage: "bookmark")
                }
            }
            
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                //.font(.title2)
                .contentShape(Rectangle())
        }
    }
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
