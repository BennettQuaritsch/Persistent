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
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // Models
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject private var storeManager: StoreManager
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \HabitTag.name, ascending: true)]) var tags: FetchedResults<HabitTag>
    
    @ObservedObject var viewModel: AddEditViewModel
    
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
            string = String(localized: "AddEditBase.Tags.NoneSelected")
        }
        
        return string
    }
    
    var backgroundColor: Color {
        if colorScheme == .dark {
            return .secondarySystemGroupedBackground
        } else {
            return .systemBackground
        }
    }
    
    enum TextFieldFocusEnum: Hashable {
        case name, valueType, standardAdd
    }
    
    @FocusState private var textFieldFocus: TextFieldFocusEnum?
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    TextField("AddEditBase.NameHeader", text: $viewModel.name)
                        .textFieldStyle(.continuousRounded(backgroundColor))
                        .focused($textFieldFocus, equals: .name)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("AddEditBase.ValueType.Header")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        NavigationLink(value: AddEditViewNavigationEnum.valueTypePicker) {
                            Text(LocalizedStringKey(viewModel.valueTypeSelection.localizedNameString))
                                .padding(10)
                                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("AddEditBase.IntervalHeader")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        ResertIntervalPickerView(
                            breakHabitEnum: viewModel.buildOrBreakHabit, intervalChoice: $viewModel.intervalChoice,
                            valueString: $viewModel.valueString,
                            timesPerDay: $viewModel.amountToDo,
                            valueTypeSelection: $viewModel.valueTypeSelection,
                            valueTypeTextFieldSelected: _textFieldFocus
                        )
                        .textFieldStyle(.continuousRounded(backgroundColor))
                        
                        HStack {
                            Text("AddEditBase.AddAmount")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                            
                            TextField("AddEditBase.AddAmountTextField", text: $viewModel.standardAddValueTextField, prompt: Text("AddEditBase.AddAmountTextField.Prompt"))
                                .textFieldStyle(.continuousRounded(backgroundColor))
                                .keyboardType(.decimalPad)
                                .focused($textFieldFocus, equals: .standardAdd)
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
                        Text("AddEditBase.BuildOrBreak.Header")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        Picker("AddEditBase.BuildOrBreak.Picker", selection: $viewModel.buildOrBreakHabit) {
                            ForEach(BuildOrBreakHabitEnum.allCases, id: \.self) { habitCase in
                                Text(habitCase.loccalizedName).tag(habitCase)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text("AddEditBase.IconColor.Header")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        SymbolColorView(iconChoice: $viewModel.iconChoice, colorSelection: $viewModel.colorSelection, colorSelectionName: $viewModel.iconColorName)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("AddEditBase.Tags.Header")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        NavigationLink(tagNames, value: AddEditViewNavigationEnum.tags)
                            .padding(10)
                            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("AddEditBase.Notifications.Header")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        
                        if purchaseInfo.wrappedValue {
                            NavigationLink(value: AddEditViewNavigationEnum.notifications) {
                                Text("AddEditBase.Notifications.Name \(viewModel.notificationsViewModel.notifcationArray.count)")
                                
                            }
                            .padding(10)
                            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        } else {
                            Button {
                                if !purchaseInfo.wrappedValue {
                                    buyPremiumAlert = true
                                }
                            } label: {
                                HStack {
                                    Text("AddEditBase.Notifications.Header")
                                        .foregroundStyle(.secondary)
                                }
                                .contentShape(Rectangle())
                            }
                            .padding(10)
                            .background(backgroundColor, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        }
                    }

                    Button("AddEditBase.SaveHabitButton", action: saveButtonAction)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(15)
                        .foregroundColor(.systemBackground)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                }
                .padding()
                .scrollDismissesKeyboard(.immediately)
            }
            .scrollDismissesKeyboard(.immediately)
//            .background(Color.systemGroupedBackground, ignoresSafeAreaEdges: .all)
            .background {
                Color.systemGroupedBackground
                    .transaction { transaction in
                        transaction.disablesAnimations = true
                    }
                    .edgesIgnoringSafeArea(.all)
            }
            .zIndex(1)
            .alert("AddEditBase.NotificationsPremiumPurchaseAlert.Header", isPresented: $buyPremiumAlert) {
                Button("AddEditBase.NotificationsPremiumPurchaseAlert.Cancel") {
                    buyPremiumAlert = false
                }
                
                Button("AddEditBase.NotificationsPremiumPurchaseAlert.Purchase") {
                    buyPremiumViewSelected = true
                }
            } message: {
                Text("AddEditBase.NotificationsPremiumPurchaseAlert.Message")
            }
            .sheet(isPresented: $buyPremiumViewSelected) { 
                NavigationStack {
                    BuyPremiumView()
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button(role: .cancel) {
                                    buyPremiumViewSelected = false
                                } label: {
                                    Text("General.Buttons.Close")
                                }
                            }
                        }
                }
                    .accentColor(userSettings.accentColor)
                    .environmentObject(userSettings)
                    .environmentObject(appViewModel)
                    .environmentObject(storeManager)
                    .environment(\.horizontalSizeClass, horizontalSizeClass)
                    .environment(\.purchaseInfo, purchaseInfo)
                    .preferredColorScheme(colorScheme)
            }
            
//            VStack {
//                Spacer()
//
//                HStack {
//                    Spacer()
//
//                    if textFieldFocus == .valueType || textFieldFocus == .standardAdd {
//                        Button {
//                            textFieldFocus = nil
//                        } label: {
//                            Image(systemName: "keyboard.chevron.compact.down")
//                                .imageScale(.large)
//                                .fontWeight(.semibold)
//                                .padding()
//                                .background(colorScheme == .dark ? Color.systemGray5 : Color.systemBackground, in: Capsule())
//                        }
//                        .accessibilityLabel("Dismiss Keyboard")
//                        .padding()
//                        .transition(.opacity.animation(.easeInOut(duration: 0.05)))
//                        .animation(.easeInOut(duration: 0.07), value: textFieldFocus)
//                    }
//                }
//            }
//            .zIndex(2)
            
            if standardAddHelpShown {
                VStack(spacing: 5) {
                    Text("AddEditBase.StandardAddHelp.Header")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text("AddEditBase.StandardAddHelp.Body1")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    
                    Text("AddEditBase.StandardAddHelp.Body2")
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
        .alert("AddEditBase.AddHabitError.Header", isPresented: $viewModel.validationFailedAlert) {
            Button("AddEditBase.AddHabitError.Continue") {
                viewModel.validationFailedAlert = false
            }
        } message: {
            Text("AddEditBase.AddHabitError.Message")
        }
        .navigationDestination(for: AddEditViewNavigationEnum.self) { navigation in
            switch navigation {
            case .valueTypePicker:
                ValueTypeSelectionView(navigationPath: $navigationPath, selection: $viewModel.valueTypeSelection, viewModel: viewModel)
            case .icons:
                ChooseIconView(iconChoice: $viewModel.iconChoice)
            case .tags:
                NewTagSection(viewModel: viewModel)
            case .notifications:
                NotificationsView(viewModel: viewModel.notificationsViewModel)
            }
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
