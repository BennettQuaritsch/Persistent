//
//  OnboardingView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 08.08.22.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.purchaseInfo) var purchaseInfo
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    // Models
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject private var storeManager: StoreManager
    
    @State private var tabViewSelection: Int = 1
    
    @State private var addSheetPresented: Bool = false
    
    @State private var quickStartHabit: AddHabitQuickStart?
    @State private var addCustomHabit: Bool = false
    
    var body: some View {
        TabView(selection: $tabViewSelection) {
            VStack {
                Text("Onboarding.FirstTab.Title")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(Color("Persistent"))
                    .multilineTextAlignment(.center)
                
                Spacer()
                    .frame(maxWidth: .infinity, maxHeight: 15)
                
                ViewThatFits(in: .vertical) {
                    VStack(alignment: .leading, spacing: 20) {
                        OnboardingTextSection(systemImage: "plus", text: "Onboarding.FirstTab.AddHabits")
                        
                        OnboardingTextSection(systemImage: "calendar", text: "Onboarding.FirstTab.Calendar")
                        
                        OnboardingTextSection(systemImage: "square.stack.3d.down.forward.fill", text: "Onboarding.FirstTab.Widgets")
                    }
                    .font(.system(.title2, design: .rounded, weight: .semibold))
                    
                    VStack(alignment: .leading, spacing: 20) {
                        OnboardingTextSection(systemImage: "plus", text: "Onboarding.FirstTab.AddHabits")
                        
                        OnboardingTextSection(systemImage: "calendar", text: "Onboarding.FirstTab.Calendar")
                        
                        OnboardingTextSection(systemImage: "square.stack.3d.down.forward.fill", text: "Onboarding.FirstTab.Widgets")
                    }
                    .font(.system(.title3, design: .rounded, weight: .semibold))
                    
                    VStack(alignment: .leading, spacing: 20) {
                        OnboardingTextSection(systemImage: "plus", text: "Onboarding.FirstTab.AddHabits")
                        
                        OnboardingTextSection(systemImage: "calendar", text: "Onboarding.FirstTab.Calendar")
                        
                        OnboardingTextSection(systemImage: "square.stack.3d.down.forward.fill", text: "Onboarding.FirstTab.Widgets")
                    }
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                }
                
                Spacer(minLength: 80)
                    
            }
            .padding(.vertical, 50)
            .padding(.horizontal, 25)
            .tag(1)
            
            VStack {
                Text("Onboarding.SecondTab.Title")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(Color("Persistent"))
                    .multilineTextAlignment(.center)
                
                Spacer()
                    .frame(maxWidth: .infinity, maxHeight: 15)
                
                VStack(spacing: 10) {
                    
                    Text("Onboarding.SecondTab.QuickAdd.Header")
                        .font(.system(.title2, design: .rounded, weight: .semibold))
                    
                    HStack {
                        Image(systemName: "plus")
                        
                        Text("DetailView.QuickAdd.Button")
                    }
                    .padding()
                    .foregroundColor(.systemBackground)
                    .font(.title3.weight(.semibold))
                    .background(Color("Persistent"), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    
                    Text("Onboarding.SecondTab.QuickAdd.Footer")
                        .font(.system(.title2, design: .rounded, weight: .semibold))
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                    
            }
            .padding(.vertical, 50)
            .padding(.horizontal, 25)
            .tag(2)
            
            VStack {
                Text("Onboarding.ThirdTab.Title")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(Color("Persistent"))
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 15) {
                    ScrollView {
                        ForEach(AddHabitQuickStart.allCases) { quickStart in
                            Button {
                                quickStartHabit = quickStart
                            } label: {
                                HStack {
                                    quickStart.image
                                        .frame(height: 50)
                                    
                                    Text(quickStart.name)
                                        .font(.title3.weight(.semibold))
                                    
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity)
                                .padding(10)
                                .background(colorScheme == .dark ? Color.systemGray5 : Color.systemGray6, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                            }
                            .sheet(item: $quickStartHabit) {
                                dismiss()
                            } content: { quickStartHabit in
                                AddHabitView(accentColor: Color("Persistent"), viewModel: quickStartHabit.viewModel)
                                    .accentColor(userSettings.accentColor)
                                    .environmentObject(userSettings)
                                    .environmentObject(appViewModel)
                                    .environmentObject(storeManager)
                                    .environment(\.horizontalSizeClass, horizontalSizeClass)
                                    .environment(\.purchaseInfo, purchaseInfo)
                                    .preferredColorScheme(colorScheme)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Spacer()
                    .frame(height: 80)
                    
            }
            .padding(.vertical, 50)
            .padding(.horizontal, 25)
            .tag(3)
        }
        .tabViewStyle(.page)
        .overlay(alignment: .bottom) {
            VStack {
                Button {
                    dismiss()
                } label: {
                    Text("Onboarding.Button.Skip")
                        .foregroundColor(Color("Persistent"))
                        .font(.body)
                        .padding(10)
                        .background(colorScheme == .dark ? Color.systemGray5 : Color.systemGray6, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                        .tint(Color("Persistent"))
                }
                
                Button {
                    if tabViewSelection != 3 {
                        withAnimation {
                            tabViewSelection += 1
                        }
                    } else {
                        dismiss()
                    }
                } label: {
                    Text(tabViewSelection != 3 ? "Onboarding.Button.Next" : "Onboarding.Button.GetStarted")
                        .foregroundColor(.systemBackground)
                        .font(.headline)
                        .padding()
                        .frame(minWidth: 200)
                        .background(Color("Persistent"), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    struct OnboardingTextSection: View {
        let systemImage: String
        let text: LocalizedStringKey
        
        var body: some View {
            HStack {
                Image(systemName: systemImage)
                    .imageScale(.large)
                    .foregroundStyle(Color("Persistent"))
                    .frame(width: 40)
                
                Text(text)
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    enum AddHabitQuickStart: String, CaseIterable, Identifiable {
        case running, meditation, read, drinkWater
        
        var name: String {
            switch self {
            case .running:
                return NSLocalizedString("Onboarding.QuickStartButton.Running.Name", comment: "")
            case .meditation:
                return NSLocalizedString("Onboarding.QuickStartButton.Meditation.Name", comment: "")
            case .read:
                return NSLocalizedString("Onboarding.QuickStartButton.Read.Name", comment: "")
            case .drinkWater:
                return NSLocalizedString("Onboarding.QuickStartButton.DrinkWater.Name", comment: "")
            }
        }
        
        var id: String {
            return self.rawValue
        }
        
        var image: some View {
            switch self {
            case .running:
                return Image("exercise")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("blue"))
            case .meditation:
                return Image("happy")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("rose"))
            case .read:
                return Image("book")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("brown"))
            case .drinkWater:
                return Image("pint")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color("teal"))
            }
        }
        
        var viewModel: AddEditViewModel {
            let viewModel = AddEditViewModel()
            
            viewModel.name = self.name
            
            switch self {
            case .running:
                viewModel.intervalChoice = .monthly
                viewModel.valueTypeSelection = .lengthKilometres
                viewModel.valueString = "20"
                viewModel.standardAddValueTextField = "5"
                
                viewModel.iconChoice = "exercise"
                viewModel.iconColorName = "Blue"
            case .meditation:
                viewModel.intervalChoice = .daily
                viewModel.valueTypeSelection = .timeMinutes
                viewModel.valueString = "15"
                viewModel.standardAddValueTextField = "5"
                
                viewModel.iconChoice = "happy"
                viewModel.iconColorName = "Rose"
            case .read:
                viewModel.intervalChoice = .weekly
                viewModel.valueTypeSelection = .timeHours
                viewModel.valueString = "3"
                viewModel.standardAddValueTextField = "1"
                
                viewModel.iconChoice = "book"
                viewModel.iconColorName = "Brown"
            case .drinkWater:
                viewModel.intervalChoice = .daily
                viewModel.valueTypeSelection = .volumeLitres
                viewModel.valueString = "3"
                viewModel.standardAddValueTextField = "0.25"
                
                viewModel.iconChoice = "pint"
                viewModel.iconColorName = "Teal"
            }
            
            return viewModel
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
