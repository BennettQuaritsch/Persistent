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
    
    @State private var habitDeleteAlertActive: Bool = false
    @State private var habitToDelete: HabitItem?

    var body: some View {
        ScrollView {
            if !items.filter({ $0.habitArchived == true }).isEmpty {
                VStack {
                    ForEach(items) { item in
                        if item.habitArchived {
                            NavigationLink(value: item) {
                                ListCellView(habit: item, viewModel: viewModel)
                                    .habitDeleteAlert(isPresented: $habitDeleteAlertActive, habit: habitToDelete, context: viewContext)
                                    .contentShape(ContentShapeKinds.contextMenuPreview, RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .contextMenu {
                                        Button {
                                            withAnimation {
                                                item.unarchiveHabit(context: viewContext)
                                            }
                                        } label: {
                                            Label("Unrchive", systemImage: "archivebox")
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
                }
            } else {
                VStack {
                    Text("Archive Habits in their context menus. This will remove their notifications.")
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }
            
            
            
        }
        .background(Color.systemGroupedBackground)
        #if os(iOS)
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("Settings.Habits.Archived")
        #endif
    }
}

struct ArchivedListView_Previews: PreviewProvider {
    static var previews: some View {
        ArchivedListView()
    }
}
