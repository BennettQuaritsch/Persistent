//
//  WatchHabitDetailView.swift
//  PersistentWatch WatchKit Extension
//
//  Created by Bennett Quaritsch on 06.01.22.
//

import SwiftUI

struct WatchHabitDetailView: View {
    @StateObject private var viewModel: WatchHabitDetailViewModel
    
    init(habit: HabitItem) {
        self._viewModel = StateObject(wrappedValue: WatchHabitDetailViewModel(habit: habit))
    }
    var body: some View {
        VStack {
            Text(viewModel.habit.habitName)
                .font(.headline)
            
            ZStack {
                ProgressBar(strokeWidth: 10, progress: CGFloat(viewModel.habit.relevantCount()) / CGFloat(viewModel.habit.amountToDo), color: viewModel.habit.iconColor)
                    .frame(minWidth: 50, maxWidth: 70)
                
//                Image(viewModel.habit.iconName!)
//                    .resizable()
//                    .scaledToFit()
//                    .foregroundColor(viewModel.habit.iconColor)
//                    .padding(15)
                
                Text("\(viewModel.habit.relevantCount())/\(viewModel.habit.amountToDo)")
                    .font(.title3.weight(.bold))
            }
            .padding(.top, 10)
            
            HStack {
                Button(action: {}) {
                    Image(systemName: "minus.circle.fill")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        
                }
                .buttonStyle(.plain)
                .frame(width: 30, height: 30)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        
                }
                .buttonStyle(.plain)
                .frame(width: 30, height: 30)
            }
//            .padding()
        }
    }
}

struct WatchHabitDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = PersistenceController.preview.container.viewContext
        
        let habit = HabitItem(context: moc)
        habit.id = UUID()
        habit.habitName = "PreviewTest"
        habit.iconName = iconSections.randomElement()!.iconArray.randomElement()!
        habit.resetIntervalEnum = .daily
        habit.amountToDo = 4
        habit.iconColorIndex = Int16(iconColors.firstIndex(of: iconColors.randomElement()!)!)
        
        let dateItem = HabitCompletionDate(context: moc)
        dateItem.date = Date()
        dateItem.habitValue = Int32(Int.random(in: 2...7))
        dateItem.item = habit
        
        return WatchHabitDetailView(habit: habit)
    }
}
