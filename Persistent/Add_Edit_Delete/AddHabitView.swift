//
//  AddHabitView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 14.05.21.
//

import SwiftUI
import CoreData

struct AddHabitView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.purchaseInfo) var purchaseInfo
    
    let accentColor: Color
    
    @StateObject private var viewModel: AddEditViewModel = AddEditViewModel()
    
    @FocusState private var valueTypeTextFieldSelected: Bool
    
    var body: some View {
        NavigationView {
            EditHabitBaseView(viewModel: viewModel, saveButtonAction: {
                viewModel.addHabit(viewContext: viewContext, dismiss: dismiss)
            })
            #if os(iOS)
            .navigationTitle(viewModel.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Create a Habit" : viewModel.name)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        viewModel.addHabit(viewContext: viewContext, dismiss: dismiss)
                    } label: {
                        #if os(iOS)
                        Label("Save", systemImage: "plus")
                        #else
                        Text("Save")
                        #endif
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("Close")
                    }
                }
            }
        }
        .accentColor(accentColor)
    }
    
    var addHabitButton: some View {
        Button("Add your Habit") {
            viewModel.addHabit(viewContext: viewContext, dismiss: dismiss)
        }
    }
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitView(accentColor: Color.accentColor)
            .previewDevice("iPhone 12")
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
