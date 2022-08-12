//
//  EditHabitBaseView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 30.12.21.
//

import SwiftUI

struct AlternativeEditHabitBaseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.purchaseInfo) var purchaseInfo
    @Environment(\.colorScheme) var colorScheme
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \HabitTag.name, ascending: true)]) var tags: FetchedResults<HabitTag>
    
    @ObservedObject var viewModel: AddEditViewModel
    
    @FocusState private var valueTypeTextFieldSelected: Bool
    @FocusState private var standardAddTextFieldSelected: Bool
    
    let saveButtonAction: () -> Void
    
    @State private var buyPremiumViewSelected: Bool = false
    @State private var buyPremiumAlert: Bool = false
    
    @Binding var navigationPath: [AddEditViewNavigationEnum]
    
    @State private var standardAddHelpShown: Bool = false
    
    var tagNames: String {
        var string: String = ""
        
        let filteredTags = tags.filter { viewModel.tagSelection.contains($0.wrappedId) }
        
        for tag in filteredTags {
            string += "\(tag.wrappedName), "
        }
        
        if !string.isEmpty {
            string.removeLast(2)
        } else {
            string = "None selected"
        }
        
        return string
    }
    
    var notificationName: String {
        let count = viewModel.notificationsViewModel.notifcationArray.count
        
        if count == 0 {
            return "No Notifications"
        }
        
        if count == 1 {
            return "1 Notifcation"
        }
        
        return "\(count) Notifications"
    }
    
    var backgroundColor: Color {
        if colorScheme == .dark {
            return .secondarySystemGroupedBackground
        } else {
            return .systemBackground
        }
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    TextField("Name", text: $viewModel.name)
                        .textFieldStyle(.continuousRounded(backgroundColor))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Value Type")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        NavigationLink(value: AddEditViewNavigationEnum.valueTypePicker) {
                            Text(viewModel.valueTypeSelection.localizedNameString)
                                .padding(10)
                                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Interval")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        ResertIntervalPickerView(
                            intervalChoice: $viewModel.intervalChoice,
                            valueString: $viewModel.valueString,
                            timesPerDay: $viewModel.amountToDo,
                            valueTypeSelection: $viewModel.valueTypeSelection,
                            valueTypeTextFieldSelected: _valueTypeTextFieldSelected
                        )
                        .textFieldStyle(.continuousRounded(backgroundColor))
                        
                        HStack {
                            Text("Add Amount")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                            
                            TextField("Standard Add-Value", text: $viewModel.standardAddValueTextField, prompt: Text("optional"))
                                .textFieldStyle(.continuousRounded(backgroundColor))
                                .keyboardType(.decimalPad)
                                .focused($standardAddTextFieldSelected)
                                .overlay(alignment: .trailing) {
                                    Button {
                                        withAnimation {
                                            standardAddHelpShown = true
                                        }
                                    } label: {
                                        Image(systemName: "questionmark.circle")
                                    }
                                    .padding(.trailing, 10)
                                }
                        }
                    }
                    
                    
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("I want to...")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        Picker("I want to", selection: $viewModel.buildOrBreakHabit) {
                            ForEach(BuildOrBreakHabitEnum.allCases, id: \.self) { habitCase in
                                Text(habitCase.rawValue).tag(habitCase)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Icon & Color")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        SymbolColorView(iconChoice: $viewModel.iconChoice, colorSelection: $viewModel.colorSelection, colorSelectionName: $viewModel.iconColorName)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Tags")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        NavigationLink(tagNames, destination: NewTagSection(viewModel: viewModel))
                            .padding(10)
                            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Notifications")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        if purchaseInfo.wrappedValue {
                            NavigationLink(notificationName, destination: NewNotificationsView(viewModel: viewModel.notificationsViewModel))
                            .padding(10)
                            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        } else {
                            Button {
                                if !purchaseInfo.wrappedValue {
                                    buyPremiumAlert = true
                                }
                            } label: {
                                HStack {
                                    Text("Notifcations")
                                        .foregroundStyle(.secondary)
                                }
                                .contentShape(Rectangle())
                            }
                            .padding(10)
                            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        }
                    }

                    Button("Save Habit", action: saveButtonAction)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(15)
                        .foregroundColor(.systemBackground)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .padding()
            }
            .background(Color.systemGroupedBackground, ignoresSafeAreaEdges: .all)
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
            if standardAddHelpShown {
                VStack(spacing: 5) {
                    Text("Standard-Add Amount")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text("This is the amount you add (or remove) from your habit from the selected day when you click the plus (or minus) button in the detail view of the habit or the small habit button in the list view.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    
                    Text("If left empty, the Standard-Add Amount will be one.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    standardAddHelpShown = false
                }
                .padding()
                .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .transition(.popUpScaleTransition)
                .padding()
                .zIndex(3)
            }
        }
//        .onTapGesture {
//            if standardAddHelpShown {
//                standardAddHelpShown = false
//            }
//        }
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

struct AlternativeEditHabitBaseViewPreviewWrapper: View {
    @State private var path: [AddEditViewNavigationEnum] = []
    var body: some View {
        NavigationStack {
            AlternativeEditHabitBaseView(viewModel: AddEditViewModel(), saveButtonAction: {}, navigationPath: $path)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}

struct AlternativeEditHabitBaseView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            
        }
            .sheet(isPresented: .constant(true)) {
                NavigationStack {
                    AlternativeEditHabitBaseViewPreviewWrapper()
                }
                .colorScheme(.dark)
            }
            
    }
}
