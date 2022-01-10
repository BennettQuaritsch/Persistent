//
//  ArchivedListView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 27.12.21.
//

import SwiftUI

struct ArchivedListView: View {
    #if os(iOS)
    @Environment(\.editMode) private var editMode
    #endif
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject private var appViewModel: AppViewModel
    
    @FetchRequest(entity: HabitItem.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HabitItem.habitName, ascending: true)]) var items: FetchedResults<HabitItem>

    @State private var selection = Set<UUID>()
    
    @StateObject var viewModel: ListViewModel = .init()

    var body: some View {
//        List(selection: $selection) {
//            ForEach(items, id: \.id) { habit in
//                if habit.habitArchived {
//                    ListCellView(habit: habit, viewModel: ListViewModel())
//                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
//                            Button {
//                                withAnimation {
//                                    habit.habitArchived = false
//
//                                    do {
//                                        try viewContext.save()
//                                    } catch {
//                                        let nsError = error as NSError
//                                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//                                    }
//                                }
//                            } label: {
//                                Label("Undo Archive", systemImage: "trash.slash")
//                            }
//                            .tint(.green)
//                        }
//                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
//                            Button(role: .destructive) {
//                                withAnimation {
//                                    habit.deleteHabitPermanently()
//
//                                    do {
//                                        try viewContext.save()
//                                    } catch {
//                                        let nsError = error as NSError
//                                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//                                    }
//                                }
//                            } label: {
//                                Label("Final Delete", systemImage: "trash")
//                            }
//                        }
//                }
//            }
//            #if os(iOS)
//            .onChange(of: editMode?.wrappedValue) { _ in
//                selection = []
//            }
//            #endif
//        }
        ScrollView {
            if !items.filter({ $0.habitArchived == true }).isEmpty {
                ForEach(items) { item in
                    if item.habitArchived {
                        NavigationLink(destination: HabitDetailView(habit: item)) {
                            ListCellView(habit: item, viewModel: viewModel)
                        }
                        .buttonStyle(.plain)
                        .contentShape(ContentShapeKinds.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .contextMenu {
                            Button {
                                withAnimation {
                                    item.unarchiveHabit()
                                }
                            } label: {
                                Label("Unrchive", systemImage: "archivebox")
                            }
                            
                            Button(role: .destructive) {
                                withAnimation {
                                    appViewModel.habitToDelete = item
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top)
                    }
                }
            } else {
                VStack {
                    Text("It's empty here ☹️")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding()
                        
                    Text("Archive Habits in their context menus. This will remove their notifications.")
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            
            
            
        }
        .background(Color("systemGroupedBackground"))
        #if os(iOS)
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Archived Habits")
        #endif
    }
}

struct ArchivedListView_Previews: PreviewProvider {
    static var previews: some View {
        ArchivedListView()
    }
}
