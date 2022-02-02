//
//  HabitSpecificGraphsView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 08.10.21.
//

import SwiftUI

struct HabitSpecificGraphsView: View {
    @ObservedObject var habit: HabitItem
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.purchaseInfo) var purchaseInfo
    
    init(habit: HabitItem) {
        self._barChartViewModel = StateObject(wrappedValue: HabitBarChartViewModel(habit: habit))
        
        self.habit = habit
    }
    
    @StateObject var barChartViewModel: HabitBarChartViewModel
    
    @State private var buyPremiumViewSelected: Bool = false
    
//    @State var graphPickerSelection: HabitBarChartViewModel.GraphPickerSelectionEnum = .weekly
    
    func formatDoubleNumberTwoDigits(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        guard let string = formatter.string(from: value as NSNumber) else { return "" }
        return string
    }
    
    func formatDoubleNumberNoDigits(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 0
        guard let string = formatter.string(from: value as NSNumber) else { return "" }
        return string
    }
    
    var body: some View {
        NavigationView {
//            List {
////                ListCellView(habit: habit, viewModel: ListViewModel())
////                    .disabled(true)
//
//                Section {
//                    Picker("Interval", selection: $barChartViewModel.graphPickerSelection) {
//                        ForEach(HabitBarChartViewModel.GraphPickerSelectionEnum.allCases, id: \.self) { selection in
//                            Text(selection.name(habit: habit)).tag(selection)
//                        }
//                    }
//                    .pickerStyle(.segmented)
//                    .onChange(of: barChartViewModel.graphPickerSelection) { selection in
//                        switch habit.resetIntervalEnum {
//                        case .daily:
//                            switch selection {
//                            case .smallView:
//                                barChartViewModel.loadDailyHabits()
//                            case .mediumView:
//                                barChartViewModel.loadMonthlyHabits()
//                            }
//                        case .weekly:
//                            barChartViewModel.loadHabitsForWeeklyHabit(selection)
//                        case .monthly:
//                            barChartViewModel.loadDataForMonthlyHabit(selection)
//                        }
//                    }
//
//                    ZStack {
//                        HabitCompletionGraph(viewModel: barChartViewModel)
//                            .aspectRatio(2 / 1.2, contentMode: .fit)
//                            .blur(radius: purchaseInfo.wrappedValue ? 0 : 10)
//
//                        if !purchaseInfo.wrappedValue {
//                            Button {
//                                buyPremiumViewSelected = true
//                            } label: {
//                                Label("Unlock Graphs for your Widget and support me 😄", systemImage: "lock.open.fill")
//                                    .font(.headline)
//                                    //.multilineTextAlignment(.center)
//                                    .foregroundColor(.primary)
//                                    .padding(10)
//                            }
//                            .buttonStyle(.borderedProminent)
//
//                            NavigationLink(destination: BuyPremiumView(), isActive: $buyPremiumViewSelected) {
//                                EmptyView()
//                            }
//                            .hidden()
//                            //.shadow(radius: 6)
//                        }
//                    }
//                }
//            }
            VStack {
                HStack {
                    if let first = barChartViewModel.shownDates.first, let last = barChartViewModel.shownDates.last {
                        GroupBox {
                            VStack {
                                let successfulCompletions = habit.getSuccessfulCompletionsForInterval(firstDate: first, lastDate: last)
                                
                                if habit.breakHabit {
                                    Text("Failed")
                                }
                                
                                Text(String(successfulCompletions) + (successfulCompletions == 1 ? " time" : " times"))
                                    .frame(maxWidth: .infinity)
                                    .font(.title3.weight(.bold))
                                
                                if !habit.breakHabit {
                                    Text("completed successfully")
                                }
                            }
                            .frame(minHeight: 50, maxHeight: 80)
                        }
                        .multilineTextAlignment(.center)
                        
                        GroupBox {
                            VStack {
                                if habit.breakHabit {
                                    Text("Succeeded")
                                }
                                
                                Text(formatDoubleNumberNoDigits(habit.getPercentageDoneForInterval(firstDate: first, lastDate: last)) + "%")
                                    .frame(maxWidth: .infinity)
                                    .font(.title3.weight(.bold))
                                
                                if habit.breakHabit {
                                    Text("on average")
                                } else {
                                    Text("completed on average")
                                }
                            }
                            .frame(minHeight: 50, maxHeight: 80)
                        }
                        .multilineTextAlignment(.center)
                    }
                }
                
                GroupBox {
                    Picker("Interval", selection: $barChartViewModel.graphPickerSelection) {
                        ForEach(HabitBarChartViewModel.GraphPickerSelectionEnum.allCases, id: \.self) { selection in
                            Text(selection.name(habit: habit)).tag(selection)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: barChartViewModel.graphPickerSelection) { selection in
                        barChartViewModel.currentDate = Date()
                        barChartViewModel.loadHabits(selection)
                    }
                    
                    ZStack {
                        HabitCompletionGraph(viewModel: barChartViewModel)
                            .aspectRatio(2 / 1.2, contentMode: .fit)
                            .blur(radius: purchaseInfo.wrappedValue ? 0 : 10)
                        
                        if !purchaseInfo.wrappedValue {
                            Button {
                                buyPremiumViewSelected = true
                            } label: {
                                Label("Unlock Graphs for your Widget and support me 😄", systemImage: "lock.open.fill")
                                    .font(.headline)
                                    //.multilineTextAlignment(.center)
                                    .foregroundColor(.primary)
                                    .padding(10)
                            }
                            .buttonStyle(.borderedProminent)
                            
                            NavigationLink(destination: BuyPremiumView(), isActive: $buyPremiumViewSelected) {
                                EmptyView()
                            }
                            .hidden()
                            //.shadow(radius: 6)
                        }
                    }
                    .frame(maxWidth: .infinity)
                } label: {
                    
                }
                .frame(minWidth: 300, maxWidth: .infinity)
                
                Spacer()
            }
            // Ohne gibt es eine weirde Insert Transition
            .transition(.move(edge: .top))
            .padding()
            .navigationTitle("Graphs")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("Close")
                    }
                }
            }
        }
    }
}

struct HabitSpecificGraphsView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = PersistenceController().container.viewContext
        
        let habit = HabitItem(context: moc)
        habit.id = UUID()
        habit.habitName = "PreviewTest"
        habit.iconName = iconSections.randomElement()!.iconArray.randomElement()!
        habit.resetIntervalEnum = .daily
        habit.amountToDo = 4
        habit.iconColorIndex = Int16(iconColors.firstIndex(of: iconColors.randomElement()!)!)
        
        for _ in 1...Int.random(in: 1...6) {
            let date = HabitCompletionDate(context: moc)
            date.date = Date()
            date.item = habit
        }
        
        return HabitSpecificGraphsView(habit: habit)
    }
}
