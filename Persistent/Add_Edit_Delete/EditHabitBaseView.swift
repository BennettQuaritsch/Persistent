//
//  EditHabitBaseView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 30.12.21.
//

import SwiftUI

struct EditHabitBaseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.purchaseInfo) var purchaseInfo
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \HabitTag.name, ascending: true)]) var tags: FetchedResults<HabitTag>
    
    @ObservedObject var viewModel: AddEditViewModel
    
    @FocusState private var valueTypeTextFieldSelected: Bool
    @FocusState private var standardAddTextFieldSelected: Bool
    
    let saveButtonAction: () -> Void
    
    @State private var buyPremiumViewSelected: Bool = false
    @State private var buyPremiumAlert: Bool = false
    
    @State private var valueTypePickerNavigationActive: Bool = false
    
    var body: some View {
        ZStack {
            List {
                TextField("Name", text: $viewModel.name)

                Section(header: Text("How often?")) {
                    NavigationLink(value: AddEditViewNavigationEnum.valueTypePicker) {
                        Text("Value Type")
                        
                        Spacer()
                        
                        Text(viewModel.valueTypeSelection.localizedNameString)
                    }
//                    
//                    ResertIntervalPickerView(
//                        intervalChoice: $viewModel.intervalChoice,
//                        valueString: $viewModel.valueString,
//                        timesPerDay: $viewModel.amountToDo,
//                        valueTypeSelection: $viewModel.valueTypeSelection,
//                        valueTypeTextFieldSelected: _valueTypeTextFieldSelected
//                    )
                    
                    TextField("Standard Add-Value", text: $viewModel.standardAddValueTextField, prompt: Text("Standard Add-Value (optional)"))
                        .keyboardType(.decimalPad)
                        .focused($standardAddTextFieldSelected)
                }
                
                Section(header: Text("What do you want?")) {
                    Picker("I want to", selection: $viewModel.buildOrBreakHabit) {
                        ForEach(BuildOrBreakHabitEnum.allCases, id: \.self) { habitCase in
                            Text(habitCase.rawValue).tag(habitCase)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Icon & Color")) {
                    SymbolColorView(iconChoice: $viewModel.iconChoice, colorSelection: $viewModel.colorSelection, colorSelectionName: $viewModel.iconColorName)
                }

                Section(header: Text("Tags")) {
                    NavigationLink("Tags", value: AddEditViewNavigationEnum.tags)
                }

                Section(header: Text("Notifications")) {
                    if purchaseInfo.wrappedValue {
                        NavigationLink(destination: NotificationsView(viewModel: viewModel.notificationsViewModel)) {
                            Text("Notifications")
                        }
                    } else {
                        ZStack {
                            NavigationLink(destination: BuyPremiumView()) {
                                EmptyView()
                            }
                            .hidden()
                            
                            Button {
                                if !purchaseInfo.wrappedValue {
                                    buyPremiumAlert = true
                                }
                            } label: {
                                HStack {
                                    Text("Notifications")
                                        .foregroundStyle(.secondary)
                                    
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                            .frame(maxWidth: .infinity)
                            
                        }
                    }
                }

                Button("Save Habit", action: saveButtonAction)
                    .listRowBackground(Color.accentColor)
                    .foregroundColor(.primary)
            }
            #if os(iOS)
            .listStyle(.insetGrouped)
            #endif
            .zIndex(1)
            .alert("You can't set notifications for habits", isPresented: $buyPremiumAlert) {
                Button("Not interested") {
                    buyPremiumAlert = false
                }
                
                Button("Show me!") {
                    buyPremiumViewSelected = true
                }
            } message: {
                Text("If you want to set notifications, you will need Persistent Premium.")
            }
            
            if valueTypeTextFieldSelected || standardAddTextFieldSelected {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button {
                            valueTypeTextFieldSelected = false
                            standardAddTextFieldSelected = false
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
                .transition(.opacity.animation(.easeInOut(duration: 0.07)))
                .zIndex(2)
            }
        }
        .alert("Failed to save habit", isPresented: $viewModel.validationFailedAlert) {
            Button("Ok") {
                viewModel.validationFailedAlert = false
            }
        } message: {
            Text("Please look again if you missed to fill in some of the fields.")
        }
    }
}

struct EditHabitBaseView_Previews: PreviewProvider {
    static var previews: some View {
        EditHabitBaseView(viewModel: AddEditViewModel(), saveButtonAction: {})
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
