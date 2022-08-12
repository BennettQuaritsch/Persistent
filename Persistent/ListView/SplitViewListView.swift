//
//  SplitViewListView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 19.07.22.
//

import SwiftUI
import CoreData

struct SplitViewListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.purchaseInfo) var purchaseInfo
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.parentSizeClass) var parentSizeClass
    #endif
    
    @State private var showSettings: Bool = false
    
    @State private var purchaseAlert = false
    
    // Models
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var appViewModel: AppViewModel
    
    let filterOption: ListFilterSelectionEnum
    
    // Core Data items
    @FetchRequest(entity: HabitTag.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HabitTag.name, ascending: true)]) var tags: FetchedResults<HabitTag>
    
    @FetchRequest private var items: FetchedResults<HabitItem>

    var habitLimitReached: Bool {
        return !purchaseInfo.wrappedValue && items.count >= 3
    }
    
    init(_ filter: ListFilterSelectionEnum = .all, shownHabit: Binding<HabitItem?>, splitViewVisibility: Binding<NavigationSplitViewVisibility>) {
        
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
        
        filterOption = filter
        
        self._shownHabit = shownHabit
        self._splitViewVisibility = splitViewVisibility
    }
    
    @StateObject var viewModel: ListViewModel = .init()
    
    @Binding var shownHabit: HabitItem?
    @Binding var splitViewVisibility: NavigationSplitViewVisibility
    
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
        .background(
            Color("systemGroupedBackground")
                .edgesIgnoringSafeArea(.all)
        )
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
        .searchable(text: $viewModel.searchText, prompt: "Search for a habit")
        .toolbar {
            #if os(iOS)
            ToolbarItemGroup(placement: .navigationBarLeading) {
                if parentSizeClass == .compact {
                    Button {
                        showSettings = true
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
                
                ListMenuButton(viewModel: viewModel, filterOption: .constant(filterOption), tags: tags.map {$0})
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
                        shownHabit = habit
                        
                        splitViewVisibility = .doubleColumn
                    }
                }
            }
        }
    }
    
    @ViewBuilder func navigationCell(_ item: HabitItem) -> some View {
        Button {
            shownHabit = item
            splitViewVisibility = .doubleColumn
        } label: {
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

struct SplitViewListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SplitViewListView(shownHabit: .constant(nil), splitViewVisibility: .constant(.all))
                .environmentObject(UserSettings())
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
        .previewDevice("iPad Pro (11-inch) (3rd generation)")
        .previewInterfaceOrientation(.landscapeLeft)
            //.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

