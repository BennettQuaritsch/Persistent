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
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section(header: Text("Name & description")) {
                        TextField("Name", text: $viewModel.name)
                        
                        //TextField("Description", text: $viewModel.description)
                    }
                    
                    Section(header: Text("Value Types")) {
                        ValueTypeSelectionView(selection: $viewModel.valueTypeSelection)
                    }
                    
                    Section(header: Text("How often?")) {
                        ResertIntervalPickerView(
                            intervalChoice: $viewModel.intervalChoice,
                            valueString: $viewModel.valueString,
                            timesPerDay: $viewModel.amountToDo,
                            valueTypeSelection: $viewModel.valueTypeSelection,
                            valueTypeTextFieldSelected: _valueTypeTextFieldSelected
                        )
                    }
                    
                    Section(header: Text("Symbol & Color")) {
                        SymbolColorView(iconChoice: $viewModel.iconChoice, colorSelection: $viewModel.colorSelection)
                    }
                    
                    Section(header: Text("Tags")) {
                        NavigationLink("Tags", destination: AlternativeTagSection(selectedTags: $viewModel.tagSelection))
                    }
                    
                    Section(header: Text("Notifications")) {
                        NavigationLink(destination: NewNotificationsView(viewModel: viewModel.notificationsViewModel)) {
                            Text("Notifications")
                        }
                    }
                    
                    Button("Save Changes") {
                        viewModel.editHabit(viewContext: viewContext, dismiss: dismiss)
                    }
                }
                #if os(iOS)
                .listStyle(.insetGrouped)
                #endif
                .zIndex(1)
                
                if viewModel.valueTypeTextFieldSelectedWrapper {
                    VStack {
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                valueTypeTextFieldSelected = false
                            } label: {
                                Image(systemName: "keyboard.chevron.compact.down")
                            }
                            .imageScale(.large)
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(Capsule())
                            .contentShape(Capsule())
                            .padding()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .transition(AnyTransition.move(edge: .bottom))
                    .zIndex(2)
                }
            }
            .onChange(of: valueTypeTextFieldSelected) { value in
                withAnimation {
                    viewModel.valueTypeTextFieldSelectedWrapper = value
                }
            }
            #if os(iOS)
            .navigationBarTitle("Edit Habit")
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
        }
        .accentColor(accentColor)
        .onAppear {
            viewModel.notificationsViewModel.loadNotifications(habit: viewModel.habit!)
        }
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = PersistenceController().container.viewContext
        
        let habit = HabitItem(context: moc)
        habit.id = UUID()
        habit.habitName = "PreviewTest"
        habit.iconName = iconChoices.randomElement()!
        habit.resetIntervalEnum = .daily
        habit.amountToDo = 4
        habit.iconColorIndex = Int16(iconColors.firstIndex(of: iconColors.randomElement()!)!)
        
        for _ in 1...Int.random(in: 1...6) {
            let date = HabitCompletionDate(context: moc)
            date.date = Date()
            date.item = habit
        }
        
        return EditView(habit: habit, accentColor: Color.accentColor)
    }
}
