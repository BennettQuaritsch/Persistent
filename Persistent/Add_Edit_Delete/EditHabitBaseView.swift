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
    
    @ObservedObject var viewModel: AddEditViewModel
    
    @FocusState private var valueTypeTextFieldSelected: Bool
    
    let saveButtonAction: () -> Void
    
    @State private var buyPremiumViewSelected: Bool = false
    @State private var buyPremiumAlert: Bool = false
    
    var body: some View {
        ZStack {
            List {
                TextField("Name", text: $viewModel.name)

//                Section(header: Text("Value Types")) {
//                    ValueTypeSelectionView(selection: $viewModel.valueTypeSelection)
//                }

                Section(header: Text("How often?")) {
                    ResertIntervalPickerView(
                        intervalChoice: $viewModel.intervalChoice,
                        valueString: $viewModel.valueString,
                        timesPerDay: $viewModel.amountToDo,
                        valueTypeSelection: $viewModel.valueTypeSelection,
                        valueTypeTextFieldSelected: _valueTypeTextFieldSelected
                    )
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
                    SymbolColorView(iconChoice: $viewModel.iconChoice, colorSelection: $viewModel.colorSelection)
                }

                Section(header: Text("Tags")) {
                    NavigationLink("Tags", destination: AlternativeTagSection(selectedTags: $viewModel.tagSelection))
                }

                Section(header: Text("Notifications")) {
                    if purchaseInfo.wrappedValue {
                        NavigationLink(destination: NewNotificationsView(viewModel: viewModel.notificationsViewModel)) {
                            Text("Notifications")
                        }
                    } else {
                        ZStack {
                            NavigationLink(destination: BuyPremiumView(), isActive: $buyPremiumViewSelected) {
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
                
                Button("Ok") {
                    buyPremiumViewSelected = true
                }
            } message: {
                Text("If you want to set notifications, buy Persistent Premium")
            }
            
//            ScrollView(.vertical) {
//                VStack {
//                    TextField("Name", text: $viewModel.name)
////                        .textFieldStyle(.roundedBorder)
//                        .padding()
//                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
//                        .padding(.bottom)
//
//                    VStack {
//                        ResertIntervalPickerView(
//                            intervalChoice: $viewModel.intervalChoice,
//                            valueString: $viewModel.valueString,
//                            timesPerDay: $viewModel.amountToDo,
//                            valueTypeSelection: $viewModel.valueTypeSelection,
//                            valueTypeTextFieldSelected: _valueTypeTextFieldSelected
//                        )
//                    }
//                        .padding()
//                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
//                        .padding(.bottom)
//
//                    VStack {
//                        SymbolColorView(iconChoice: $viewModel.iconChoice, colorSelection: $viewModel.colorSelection)
//                    }
//                        .padding(.vertical)
//                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
//                        .padding(.bottom)
//
//                    NavigationLink(destination: AlternativeTagSection(selectedTags: $viewModel.tagSelection)) {
//                        HStack {
//                            Text("Tags")
//                                .foregroundColor(.primary)
//
//                            Spacer()
//                        }
//                    }
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
//                        .padding(.bottom)
//
//                    NavigationLink(destination: NewNotificationsView(viewModel: viewModel.notificationsViewModel)) {
//                        HStack {
//                            Text("Notifications")
//                                .foregroundColor(.primary)
//
//                            Spacer()
//                        }
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
//                    .padding(.bottom)
//
//                    Button(action: saveButtonAction) {
//                        Text("Save Habit")
//                            .frame(maxWidth: .infinity)
//                    }
//                        .buttonStyle(.borderedProminent)
//                        .controlSize(.large)
//                        .padding(.bottom)
//                }
//                .padding()
//            }
            
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
    }
}
