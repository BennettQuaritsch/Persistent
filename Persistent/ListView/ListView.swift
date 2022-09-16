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
    @Environment(\.interfaceColor) var interfaceColor
    
    #if os(iOS)
    //@Environment(\.editMode) var editMode
    @State var editMode: EditMode = .inactive
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.parentSizeClass) var parentSizeClass
    #endif
    
    // Models
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject private var storeManager: StoreManager
    
    @State private var showSettings: Bool = false
    @Binding var habitToEdit: HabitItem?
    
    @State private var purchaseAlert = false
    
    @State private var filterOption: ListFilterSelectionEnum = .all
    
    // Core Data Items
    @FetchRequest(entity: HabitTag.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HabitTag.name, ascending: true)]) var tags: FetchedResults<HabitTag>
    
    @FetchRequest private var items: FetchedResults<HabitItem>
    
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
    
    init(navigationPath: Binding<[HabitItem]>, habitToEdit: Binding<HabitItem?>) {
        _items = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.habitName, ascending: true)],
            animation: .easeInOut)
        
        self._navigationPath = navigationPath
        self._habitToEdit = habitToEdit
    }
    
    @StateObject var viewModel: ListViewModel = .init()
    
    @Binding var navigationPath: [HabitItem]
    
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
    
    @SceneStorage("listViewFilterOption") private var filterOptionString: String = "All Habits"
    
    @State private var habitDeleteAlertActive: Bool = false
    @State private var habitToDelete: HabitItem?
    
    var body: some View {
        ScrollView {
            if !shownItems.isEmpty {
                VStack {
                    ForEach(shownItems, id: \.id) { item in
                        if !item.habitArchived {
                            navigationCell(item)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 100)
                }
            } else {
                VStack {
                    Text("It's empty here ☹️")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .padding()
                        
                    Text("Press + to add a habit")
                        .font(.system(.body, design: .rounded, weight: .medium))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
        }
        .background(
            Color("systemGroupedBackground")
                .edgesIgnoringSafeArea(.all)
        )
        .onChange(of: filterOption) { selection in
            items.nsPredicate = predicate
            
            filterOptionString = selection.codingID
        }
        .onAppear {
            if parentSizeClass == .compact {
                filterOption = ListFilterSelectionEnum(from: filterOptionString, context: viewContext)
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
        .navigationTitle(filterOption.name)
        .searchable(text: $viewModel.searchText, prompt: "ListView.Search.Prompt")
        .toolbar {
            #if os(iOS)
            ToolbarItemGroup(placement: .navigationBarLeading) {
                if parentSizeClass == .compact {
                    Button {
                        showSettings = true
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                    .accessibilityIdentifier("SettingsButton")
                }
                
                ListMenuButton(viewModel: viewModel, filterOption: $filterOption, tags: tags.map {$0})
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
        .sheet(item: $habitToEdit) { habitItem in
            EditView(habit: habitItem, accentColor: userSettings.accentColor)
                .accentColor(userSettings.accentColor)
            .environment(\.managedObjectContext, self.viewContext)
            .environment(\.purchaseInfo, purchaseInfo)
            .environment(\.interfaceColor, interfaceColor)
        }
        .sheet(isPresented: $viewModel.addSheetPresented, content: {
            AddHabitView(accentColor: userSettings.accentColor)
                .accentColor(userSettings.accentColor)
                .environment(\.managedObjectContext, self.viewContext)
                .environment(\.purchaseInfo, purchaseInfo)
                .environment(\.interfaceColor, interfaceColor)
                .environmentObject(userSettings)
                .environmentObject(appViewModel)
                .environmentObject(storeManager)
                .environment(\.horizontalSizeClass, horizontalSizeClass)
                .preferredColorScheme(colorScheme)
        })
        .sheet(isPresented: $showSettings) {
            SettingsView()
                .accentColor(userSettings.accentColor)
                .environmentObject(userSettings)
                .environmentObject(appViewModel)
                .environmentObject(storeManager)
                .environment(\.horizontalSizeClass, horizontalSizeClass)
                .environment(\.purchaseInfo, purchaseInfo)
                .preferredColorScheme(colorScheme)
        }
        .alert("Your have reached your limit of habits", isPresented: $purchaseAlert) {
            Button("OK", role: .cancel) {
                purchaseAlert = false
            }
        } message: {
            Text("Purchase Persistent Premium to add unlimited habits and to support me 😊")
        }
        .onOpenURL { url in
            if url.pathComponents.count == 2 {
                let idString = url.pathComponents[1]
                if let id = UUID(uuidString: idString) {
                    if let habit = items.first(where: { $0.id == id }) {
                        navigationPath = [habit]
                    }
                }
            }
        }
    }
    
    @ViewBuilder func navigationCell(_ item: HabitItem) -> some View {
        NavigationLink(value: item) {
            ListCellView(habit: item, viewModel: viewModel)
                .habitDeleteAlert(isPresented: $habitDeleteAlertActive, habit: habitToDelete, context: viewContext)
                .contentShape(ContentShapeKinds.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
                .contextMenu {
                    Button {
                        habitToEdit = item
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button {
                        withAnimation {
                            item.archiveHabit(context: viewContext)
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

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ListView(navigationPath: .constant([]), habitToEdit: .constant(nil))
                .previewDevice("iPhone 12")
        }
            //.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
