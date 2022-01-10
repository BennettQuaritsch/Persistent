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
    
    @State var graphPickerSelection: HabitBarChartViewModel.GraphPickerSelectionEnum = .weekly
    
    var body: some View {
        NavigationView {
            List {
//                ListCellView(habit: habit, viewModel: ListViewModel())
//                    .disabled(true)
                
                Section {
                    Picker("Interval", selection: $graphPickerSelection) {
                        ForEach(HabitBarChartViewModel.GraphPickerSelectionEnum.allCases, id: \.self) { selection in
                            Text(selection.localizedName).tag(selection)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: graphPickerSelection) { selection in
                        switch selection {
                        case .weekly:
                            barChartViewModel.loadDailyHabits()
                        case .monthly:
                            barChartViewModel.loadMonthlyHabits()
//                            barChartViewModel.loadHabitsForWeeklyHabit()
                        }
                    }
                    
                    ZStack {
                        HabitCompletionGraph(viewModel: barChartViewModel, graphPickerSelection: $graphPickerSelection)
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
                }
                
//                Section {
//                    HabitLineChartView(habit: habit)
//                        .padding(.vertical)
//                        .aspectRatio(2 / 1.2, contentMode: .fit)
//    //                    .background(Color(UIColor.systemGray6))
//    //                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//    //                .padding(.horizontal)
//                }
            }
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
