//
//  SmallWidgetView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 27.07.21.
//

import SwiftUI
import CoreData
import WidgetKit

struct SmallWidgetView: View {
    @Environment(\.redactionReasons) var redactionReasons
    
    var habit: HabitItem?
    
    let iconColors: [Color] = [Color.primary, Color.red, Color.orange, Color.yellow, Color.green, Color.pink, Color.purple]
    
    let shownDate = Date()
    
    var body: some View {
        if redactionReasons == .placeholder {
            ZStack {
                ProgressBar(strokeWidth: 10, progress: 0, color: .black)
                
                Circle()
                    .foregroundColor(Color("systemGray6"))
                    .scaledToFit()
            }
            .padding()
        } else {
            if let habit = habit {
                ZStack {
                    ProgressBar(strokeWidth: 10, progress: habit.progress(), color: habit.iconColor)
                    
                    if habit.iconName != nil {
                        Image(habit.iconName!)
                            .resizable()
                            .foregroundColor(habit.iconColor)
                            .aspectRatio(contentMode: .fit)
                            .padding()
                    }
                }
                .padding()
            } else {
                Text("Configure your habits through long-pressing")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

struct SmallWidgetView_Previews: PreviewProvider {
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
        
        return SmallWidgetView(habit: habit)
            .previewLayout(.sizeThatFits)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
