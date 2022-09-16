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
    
    init(habit: HabitItem, accentColor: Color) {
        self._viewModel = StateObject(wrappedValue: AddEditViewModel(habit: habit))
        
        self.accentColor = accentColor
    }
    
    @StateObject private var viewModel: AddEditViewModel
    
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
    @State private var differentValueTypeAlert: Bool = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            AlternativeEditHabitBaseView(
                viewModel: viewModel,
                saveButtonAction: {
                    if let previousValueType = viewModel.previousValueType, !viewModel.valueTypeSelection.comparableTypes.contains(previousValueType) {
                        differentValueTypeAlert = true
                    } else {
                        viewModel.editHabit(viewContext: viewContext)
                        
                        dismiss()
                    }
            },
                navigationPath: $navigationPath
            )
            #if os(iOS)
            .navigationTitle(viewModel.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? NSLocalizedString("EditHabit.NavigationTitle", comment: "") : viewModel.name)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if let previousValueType = viewModel.previousValueType, !viewModel.valueTypeSelection.comparableTypes.contains(previousValueType) {
                            differentValueTypeAlert = true
                        } else {
                            viewModel.editHabit(viewContext: viewContext)
                            
                            dismiss()
                        }
                    } label: {
                        Label("General.Buttons.Save", systemImage: "checkmark")
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("General.Buttons.Close")
                    }
                    .accessibilityIdentifier("CloseButton")
                }
            }
            .alert("AddEditBase.DifferentValueTypeError.Header", isPresented: $differentValueTypeAlert) {
                Button("AddEditBase.DifferentValueTypeError.Stop", role: .cancel) {
                    
                }
                
                Button("AddEditBase.DifferentValueTypeError.Continue", role: .destructive) {
                    viewModel.editHabit(viewContext: viewContext)
                    
                    dismiss()
                }
            } message: {
                Text("AddEditBase.DifferentValueTypeError.Message")
            }
//            .navigationDestination(for: AddEditViewNavigationEnum.self) { navigation in
//                switch navigation {
//                case .valueTypePicker:
//                    ValueTypeSelectionView(navigationPath: $navigationPath, selection: $viewModel.valueTypeSelection, viewModel: viewModel)
//                case .icons:
//                    ChooseIconView(iconChoice: $viewModel.iconChoice)
//                case .tags:
//                    NewTagSection(viewModel: viewModel)
//                case .notifications:
//                    NotificationsView(viewModel: viewModel.notificationsViewModel)
//                }
//            }
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
