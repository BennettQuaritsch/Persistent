//
//  MediumGraphWidget.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 14.11.21.
//

import SwiftUI
import WidgetKit

struct MediumGraphWidgetView: View {
    let habit: HabitItem?
    
    var body: some View {
        if let habit = habit {
            HabitCompletionGraph(viewModel: HabitBarChartViewModel(habit: habit), graphPickerSelection: .constant(.weekly))
                .padding(10)
        }
    }
}

struct MediumGraphWidgetView_Previews: PreviewProvider {
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
        
        return MediumGraphWidgetView(habit: habit)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
