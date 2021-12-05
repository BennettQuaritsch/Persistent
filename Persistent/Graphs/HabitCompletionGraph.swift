//
//  HabitCompletionGraph.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 20.09.21.
//

import SwiftUI
import CoreData

struct HabitCompletionGraph: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var viewModel: HabitBarChartViewModel
    
    @Binding var graphPickerSelection: HabitBarChartViewModel.GraphPickerSelectionEnum
    
    var body: some View {
        VStack {
            switch graphPickerSelection {
            case .weekly:
                Text("Week \((viewModel.shownDates.first ?? Date()).formatted(.dateTime.week(.twoDigits)))")
                    .font(.headline)
                    .padding(.top, 8)
            case .monthly:
                Text((viewModel.shownDates.first ?? Date()).formatted(.dateTime.month(.wide)))
                    .font(.headline)
                    .padding(.top, 8)
            }
            
            GeometryReader { geo in
                HStack(alignment: .bottom, spacing: graphPickerSelection == .weekly ? 10 : 5) {
                    ForEach(viewModel.data.indices, id: \.self) { index in
                        
                        ZStack(alignment: .bottom) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .foregroundColor(Color("systemGroupedBackground"))
                            
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .foregroundColor(viewModel.habit.iconColor)
                                .frame(height: CGFloat(viewModel.data[index]) / CGFloat(viewModel.maxValue) * geo.size.height)
                        }
                            
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
            }
            
            switch graphPickerSelection {
            case .weekly:
                HStack {
                    ForEach(viewModel.shownDates, id: \.self) { date in
                        Text(date.formatted(.dateTime.weekday(.short)))
                            .font(.headline)
                    }
                    .frame(minWidth: 10, maxWidth: .infinity)
                    //.padding(.top, 8)
                }
            case .monthly:
                HStack {
                    Text((viewModel.shownDates.first ?? Date()).formatted(.dateTime.day(.twoDigits)))
                        .font(.headline)
                    
                    Spacer()
                    
                    Text((viewModel.shownDates.last ?? Date()).formatted(.dateTime.day(.twoDigits)))
                        .font(.headline)
                }
                //.padding(.top, 8)
                .padding(.horizontal)
            }
        }
        .onAppear {
            viewModel.loadDailyHabits()
        }
        
        
    }
}

struct HabitCompletionGraph_Previews: PreviewProvider {
    static var previews: some View {
        let moc = PersistenceController().container.viewContext
        
        let habit = HabitItem(context: moc)
        habit.id = UUID()
        habit.habitName = "PreviewTest"
        habit.iconName = iconChoices.randomElement()!
        habit.resetIntervalEnum = .daily
        habit.amountToDo = 4
        habit.iconColorIndex = Int16(iconColors.firstIndex(of: iconColors.randomElement()!)!)
        
        for _ in 1...Int.random(in: 1...6) {
            let date = HabitCompletionDate(context: moc)
            date.date = Date()
            date.item = habit
        }
        
        return HabitCompletionGraph(viewModel: HabitBarChartViewModel(habit: habit), graphPickerSelection: .constant(.weekly))
            .aspectRatio(1.5/1, contentMode: .fit)
            .previewLayout(.sizeThatFits)
    }
}
