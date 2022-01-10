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
    
    @State private var purchaseAlert = false
    
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var appViewModel: AppViewModel
    
    @State private var filterSelection: ListFilterSelectionEnum = .all
    
    @FetchRequest(entity: HabitTag.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HabitTag.name, ascending: true)]) var tags: FetchedResults<HabitTag>
    
    var predicate: NSPredicate? {
        switch filterSelection {
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
            animation: .default)
    }
    
    @FetchRequest private var items: FetchedResults<HabitItem>
    
//    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.habitName, ascending: true)], predicate: nil, animation: .easeInOut) var test: FetchedResults<HabitItem>
    
    //@FetchRequest(entity: HabitItem.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.habitName, ascending: true)], predicate: NSCompoundPredicate(andPredicateWithSubpredicates: []), animation: .default) var test: FetchedResults<HabitItem>
    
    @StateObject var viewModel: ListViewModel = .init()
    
    var shownItems: [HabitItem] {
        var tempItems: [HabitItem] = []

        switch viewModel.filterOptions {
        case .nameAscending:
            tempItems = items.sorted(by: { $0.habitName < $1.habitName })
        case .nameDescending:
            tempItems = items.sorted(by: { $0.habitName > $1.habitName })
        case .percentageDoneAscending:
            tempItems = items.sorted(by: { (CGFloat($0.relevantCount()) / CGFloat($0.amountToDo)) < (CGFloat($1.relevantCount()) / CGFloat($1.amountToDo)) })
        case .percentageDoneDescending:
            tempItems = items.sorted(by: { (CGFloat($0.relevantCount()) / CGFloat($0.amountToDo)) > (CGFloat($1.relevantCount()) / CGFloat($1.amountToDo)) })
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
    
    var body: some View {
//        List(selection: $viewModel.selection) {
//            ForEach(shownItems, id: \.id) { item in
//                if !item.habitDeleted {
//                    NavigationLink(destination: HabitDetailView(habit: item)) {
//                        ListCellView(habit: item, viewModel: viewModel)
//                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
//                                Button(role: .destructive) {
//                                    item.deleteHabit()
//
//                                    do {
//                                        try viewContext.save()
//                                    } catch {
//                                        fatalError()
//                                    }
//                                } label: {
//                                    Label("Delete Habit", systemImage: "trash")
//                                        .labelStyle(.iconOnly)
//                                }
//                                .tint(.red)
//                            }
//                    }
//                }
//            }
//            #if os(iOS)
//            .onChange(of: editMode) { _ in
//                viewModel.selection = []
//                print("change")
//            }
//            #endif
//            //.listRowSeparator(.hidden)
//        }
        ScrollView {
            if !shownItems.isEmpty {
                ForEach(shownItems, id: \.id) { item in
                    if !item.habitArchived {
                        NavigationLink(tag: item.id, selection: $selectedID, destination: { HabitDetailView(habit: item) }) {
                            ListCellView(habit: item, viewModel: viewModel)
//                                .drawingGroup()
//                                .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 10)
                        }
                        .buttonStyle(.plain)
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
                                appViewModel.habitToDelete = item
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                }
                
                Spacer()
                    .frame(height: 100)
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
        .onChange(of: filterSelection) { selection in
            items.nsPredicate = predicate
        }
        .tint(.accentColor)
//        .safeAreaInset(edge: .bottom, alignment: .trailing) {
//            HStack {
//                if !userSettings.leftHandedInterface {
//                    Spacer()
//                }
//
//                ZStack {
//                    Circle()
//                        .fill(habitLimitReached ? Color.gray : Color.accentColor)
//                        .shadow(radius: 8)
//
//                    Image(systemName: "plus")
//                        .resizable()
//                        .foregroundColor(Color("systemBackground"))
//                        .frame(width: 25, height: 25)
//                }
//                .frame(width: 60, height: 60)
//                .onTapGesture {
//                    if habitLimitReached {
//                        purchaseAlert = true
//                    } else {
//                        viewModel.addSheetPresented = true
//                    }
//                }
//                .padding(EdgeInsets(top: 0, leading: 25, bottom: 25, trailing: 25))
//
//                if userSettings.leftHandedInterface {
//                    Spacer()
//                }
//            }
//        }
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
        .navigationBarTitle(filterSelection.name)
        #endif
        .toolbar {
            #if os(iOS)
//            editAndDeleteButton
            
            ToolbarItem(placement: .navigationBarLeading) {
                habitListMenu
            }
            #endif
        }
        .sheet(isPresented: $viewModel.addSheetPresented, content: {
            AddHabitView(accentColor: userSettings.accentColor)
            .environment(\.managedObjectContext, self.viewContext)
            .environment(\.purchaseInfo, purchaseInfo)
        })
        .environment(\.editMode, $editMode)
        .alert("Your have reached your limit", isPresented: $purchaseAlert) {
            Button("OK", role: .cancel) {
                purchaseAlert = false
            }
        } message: {
            Text("Purchase Premium to add unlimited habits and to support me 😊")
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
                filterSelection = filter
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
                            viewModel.filterOptions = .nameAscending
                        }
                    }

                    Button("Descending") {
                        withAnimation {
                            viewModel.filterOptions = .nameDescending
                        }
                    }
                } label: {
                    Label("Name", systemImage: "abc")
                }
                
                Menu {
                    Button("Ascending") {
                        withAnimation {
                            viewModel.filterOptions = .percentageDoneAscending
                        }
                    }
                    
                    Button("Descending") {
                        withAnimation {
                            viewModel.filterOptions = .percentageDoneDescending
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
