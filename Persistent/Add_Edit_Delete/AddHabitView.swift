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
    
    let accentColor: Color
    
    @StateObject private var viewModel: AddEditViewModel = AddEditViewModel()
    
    @FocusState private var valueTypeTextFieldSelected: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                List {
                    Section(header: Text("Name & Description")) {
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
                        //NotificationsView(viewModel: viewModel.notificationsViewModel)
                        NavigationLink(destination: NewNotificationsView(viewModel: viewModel.notificationsViewModel)) {
                            Text("Notifications")
                        }
                        .alert("That did not work", isPresented: $viewModel.notificationsViewModel.alertPresented) {
                            Button("OK", role: .cancel) {
                                viewModel.notificationsViewModel.alertPresented = false
                            }
                        } message: {
                            Text("An error accured while trying to schedule your notifications. Have you turned notifications off?")
                        }
                    }
                    
                    addHabitButton
                }
                #if os(iOS)
                .listStyle(InsetGroupedListStyle())
                #else
                .listStyle(.inset)
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
            .navigationBarTitle("Create a Habit")
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

/// View for choosing Icons from a grid.
struct ChooseIconView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let columns = [GridItem(.adaptive(minimum: 60, maximum: 80))]
    
    @Binding var iconChoice: String
    
    var body: some View {
        ZStack {
            Color("systemGray6")
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                    ForEach(iconChoices, id: \.self) { icon in
                        ZStack {
                            ZStack {
                                Image(icon)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(.primary)
                                    .padding(8)
                                
                                //Color.primary.blendMode(.sourceAtop)
                            }
                            .onTapGesture {
                                iconChoice = icon
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitView(accentColor: Color.accentColor)
            .previewDevice("iPhone 12")
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
