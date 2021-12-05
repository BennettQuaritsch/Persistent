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
    
    #if os(iOS)
    //@Environment(\.editMode) var editMode
    @State var editMode: EditMode = .inactive
    #endif
    
    @EnvironmentObject private var userSettings: UserSettings

    /// Init with optional Predicate. When predicate = nil, no predicate will be used.
    init(predicate: [NSPredicate]?) {
        if let predicate = predicate {
            let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicate)
            
            _items = FetchRequest(
                sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.habitName, ascending: true)],
                predicate: combinedPredicate,
                animation: .default)
        } else {
            _items = FetchRequest(
                sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.habitName, ascending: true)],
                animation: .default)
        }
    }
    
    init() {
        _items = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.habitName, ascending: true)],
            animation: .default)
    }
    
    @FetchRequest private var items: FetchedResults<HabitItem>
    
    //@FetchRequest(entity: HabitItem.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.habitName, ascending: true)], predicate: NSCompoundPredicate(andPredicateWithSubpredicates: []), animation: .default) var test: FetchedResults<HabitItem>
    
    @StateObject var viewModel: ListViewModel = .init()
    
    var shownItems: [HabitItem] {
//        var tempItems: [HabitItem] = []
//
//        switch viewModel.filterOptions {
//        case .nameAscending:
//            tempItems = items.sorted(by: { $0.habitName < $1.habitName })
//        case .nameDescending:
//            tempItems = items.sorted(by: { $0.habitName > $1.habitName })
//        }
        
        if viewModel.searchText.isEmpty {
            return items.map {$0}
        } else {
            return items.filter { $0.habitName.contains(viewModel.searchText) }
        }
    }

    func deleteHabitWithOffset(at offsets: IndexSet) {
        viewModel.deleteHabitWithOffset(at: offsets, items: items, context: viewContext)
    }
    
    private var isEditing: Bool {
            editMode.isEditing
        }
    
    var body: some View {
        List(selection: $viewModel.selection) {
            ForEach(shownItems, id: \.id) { item in
                if !item.habitDeleted {
                    NavigationLink(destination: HabitDetailView(habit: item)) {
                        ListCellView(habit: item, viewModel: viewModel)
                    }
                }
            }
            .onDelete(perform: deleteHabitWithOffset)
            #if os(iOS)
            .onChange(of: editMode) { _ in
                viewModel.selection = []
                print("change")
            }
            #endif
            //.listRowSeparator(.hidden)
        }
        .tint(.accentColor)
        .safeAreaInset(edge: .bottom) {
            HStack {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.accentColor)

                    Image(systemName: "plus")
                        .foregroundColor(.primary)
                }
                .frame(width: 50, height: 50)
                .onTapGesture {
                    viewModel.addSheetPresented = true
                }
                .shadow(radius: 5)
                .padding()
            }
        }
        //.listStyle(InsetGroupedListStyle())
        .searchable(text: $viewModel.searchText, prompt: "Search for a habit")
        #if os(iOS)
        .navigationBarTitle("All Habits")
        #endif
        .toolbar {
            #if os(iOS)
            editAndDeleteButton
            #endif
        }
        .sheet(isPresented: $viewModel.addSheetPresented, content: {
            AddHabitView(accentColor: userSettings.accentColor)
            .environment(\.managedObjectContext, self.viewContext)
        })
        .environment(\.editMode, $editMode)
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
