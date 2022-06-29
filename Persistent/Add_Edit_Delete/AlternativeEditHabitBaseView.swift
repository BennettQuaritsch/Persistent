//
//  AlternativeEditHabitBaseView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 10.03.22.
//

import SwiftUI

struct AlternativeEditHabitBaseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.purchaseInfo) var purchaseInfo
    
    @ObservedObject var viewModel: AddEditViewModel
    
    @FocusState private var valueTypeTextFieldSelected: Bool
    
    let saveButtonAction: () -> Void
    
    @State private var buyPremiumViewSelected: Bool = false
    @State private var buyPremiumAlert: Bool = false
    
    @FocusState private var nameTextFieldSelected: Bool
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    GroupBox {
                        TextField("Name", text: $viewModel.name)
                            .focused($nameTextFieldSelected)
                    }
                    
                    GroupBox {
                        Section(header: Text("How often?")) {
                            ResertIntervalPickerView(
                                intervalChoice: $viewModel.intervalChoice,
                                valueString: $viewModel.valueString,
                                timesPerDay: $viewModel.amountToDo,
                                valueTypeSelection: $viewModel.valueTypeSelection,
                                valueTypeTextFieldSelected: _valueTypeTextFieldSelected
                            )
                        }
                    }
                    
                    GroupBox {
                        Section(header: Text("What do you want?")) {
                            Picker("I want to", selection: $viewModel.buildOrBreakHabit) {
                                ForEach(BuildOrBreakHabitEnum.allCases, id: \.self) { habitCase in
                                    Text(habitCase.rawValue).tag(habitCase)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }

                    GroupBox {
                        Section(header: Text("Icon & Color")) {
                            SymbolColorView(iconChoice: $viewModel.iconChoice, colorSelection: $viewModel.colorSelection, colorSelectionName: $viewModel.iconColorName)
                        }
                    }

                    GroupBox {
                        Section(header: Text("Tags")) {
                            NavigationLink("Tags", destination: AlternativeTagSection(selectedTags: $viewModel.tagSelection))
                        }
                    }

                    GroupBox {
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
                    }

                    Button("Save Habit", action: saveButtonAction)
                        .listRowBackground(Color.accentColor)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
            }
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
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    nameTextFieldSelected = true
                }
            }
            
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

struct AlternativeEditHabitBaseView_Previews: PreviewProvider {
    static var previews: some View {
        AlternativeEditHabitBaseView(viewModel: AddEditViewModel(), saveButtonAction: {})
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environment(\.purchaseInfo, .constant(true))
    }
}
