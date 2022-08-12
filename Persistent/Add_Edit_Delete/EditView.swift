//
//  EditView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 25.05.21.
//

import SwiftUI
import CoreData
import UserNotifications

struct EditView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.purchaseInfo) var purchaseInfo
    
    //@StateObject private var notificationsViewModel = NotificationsViewModel()
    
    let accentColor: Color
    
    //let habit: HabitItem
    
    init(habit: HabitItem, accentColor: Color) {
        self._viewModel = StateObject(wrappedValue: AddEditViewModel(habit: habit))
        
        self.accentColor = accentColor
    }
    
    @StateObject private var viewModel: AddEditViewModel
    
    @FocusState private var valueTypeTextFieldSelected: Bool
    
    #if os(iOS)
    func habitAddedVibration() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    #endif
    
    let rows = [
            GridItem(.fixed(50), spacing: 10),
            GridItem(.fixed(50))
        ]
    
    @State private var navigationPath: [AddEditViewNavigationEnum] = []
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            AlternativeEditHabitBaseView(viewModel: viewModel, saveButtonAction: {
                viewModel.editHabit(viewContext: viewContext, dismiss: dismiss)
            }, navigationPath: $navigationPath)
            #if os(iOS)
            .navigationTitle(viewModel.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Edit Habit" : viewModel.name)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        viewModel.editHabit(viewContext: viewContext, dismiss: dismiss)
                    } label: {
                        Label("Save", systemImage: "checkmark")
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
            .navigationDestination(for: AddEditViewNavigationEnum.self) { navigation in
                switch navigation {
                case .valueTypePicker:
                    ValueTypeSelectionView(navigationPath: $navigationPath, selection: $viewModel.valueTypeSelection, viewModel: viewModel)
                }
            }
        }
        .accentColor(accentColor)
        .onAppear {
            viewModel.notificationsViewModel.loadNotifications(habit: viewModel.habit!)
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        return EditView(habit: HabitItem.testHabit, accentColor: Color.accentColor)
    }
}
