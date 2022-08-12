//
//  OnboardingView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 08.08.22.
//

import SwiftUI

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var tabViewSelection: Int = 1
    
    @State private var addSheetPresented: Bool = false
    
    @State private var quickStartHabit: AddHabitQuickStart?
    @State private var addCustomHabit: Bool = false
    
    var body: some View {
        TabView(selection: $tabViewSelection) {
            VStack {
                Text("Welcome to Persistent!")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(Color("Persistent"))
                    .multilineTextAlignment(.center)
                
                Spacer()
                    .frame(maxWidth: .infinity, maxHeight: 15)
                
                VStack(alignment: .leading, spacing: 20) {
                    OnboardingTextSection(systemImage: "plus", text: "Add Habits and customize them as much as you need them.")
                    
                    OnboardingTextSection(systemImage: "calendar", text: "If you forgot to complete your habit some days ago, you can go back to that day using the calendar.")
                    
                    OnboardingTextSection(systemImage: "square.stack.3d.down.forward.fill", text: "Use widgets to get a quick glance on how you are doing.")
                }
                
                Spacer()
                    
            }
            .padding(.vertical, 50)
            .padding(.horizontal, 25)
            .tag(1)
            
            VStack {
                Text("Add frequently used amounts")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(Color("Persistent"))
                    .multilineTextAlignment(.center)
                
                Spacer()
                    .frame(maxWidth: .infinity, maxHeight: 15)
                
                VStack(spacing: 10) {
                    
                    Text("Press the")
                        .font(.system(.title2, design: .rounded, weight: .semibold))
                    
                    HStack {
                        Image(systemName: "plus")
                        
                        Text("Quick Add")
                    }
                    .padding()
                    .foregroundColor(.systemBackground)
                    .font(.title3.weight(.semibold))
                    .background(Color("Persistent"), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    
                    Text("to save amounts that you will add to your habit frequently.")
                        .font(.system(.title2, design: .rounded, weight: .semibold))
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                    
            }
            .padding(.vertical, 50)
            .padding(.horizontal, 25)
            .tag(2)
            
            VStack {
                Text("Get started now!")
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
                                .background(Color.systemGray6, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                            }
                            .sheet(item: $quickStartHabit) {
                                dismiss()
                            } content: { quickStartHabit in
                                AddHabitView(accentColor: Color("Persistent"), viewModel: quickStartHabit.viewModel)
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
                    Text("Skip introduction")
                        .foregroundColor(Color("Persistent"))
                        .font(.body)
                        .padding(10)
                        .background(Color.systemGray6, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
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
                    Text(tabViewSelection != 3 ? "Next" : "Get started")
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
        let text: String
        
        var body: some View {
            HStack {
                Image(systemName: systemImage)
                    .imageScale(.large)
                    .foregroundStyle(Color("Persistent"))
                    .frame(width: 40)
                
                Text(text)
                    .multilineTextAlignment(.leading)
            }
            .font(.system(.title2, design: .rounded, weight: .semibold))
        }
    }
    
    enum AddHabitQuickStart: String, CaseIterable, Identifiable {
        case running, mediation, read, drinkWater
        
        var name: String {
            switch self {
            case .drinkWater:
                return "Drink Water"
            default:
                return self.rawValue.capitalized
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
            case .mediation:
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
            
            switch self {
            case .running:
                viewModel.name = "Running"
                
                viewModel.intervalChoice = .monthly
                viewModel.valueTypeSelection = .lengthKilometres
                viewModel.valueString = "20"
                viewModel.standardAddValueTextField = "5"
                
                viewModel.iconChoice = "exercise"
                viewModel.iconColorName = "Blue"
            case .mediation:
                viewModel.name = "Mediation"
                
                viewModel.intervalChoice = .daily
                viewModel.valueTypeSelection = .timeMinutes
                viewModel.valueString = "15"
                viewModel.standardAddValueTextField = "5"
                
                viewModel.iconChoice = "happy"
                viewModel.iconColorName = "Rose"
            case .read:
                viewModel.name = "Read"
                
                viewModel.intervalChoice = .weekly
                viewModel.valueTypeSelection = .timeHours
                viewModel.valueString = "3"
                viewModel.standardAddValueTextField = "1"
                
                viewModel.iconChoice = "book"
                viewModel.iconColorName = "Brown"
            case .drinkWater:
                viewModel.name = "Drink Water"
                
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
