//
//  SmallWidgetView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 27.07.21.
//

import SwiftUI
import CoreData
import WidgetKit

struct SingleWidgetView: View {
    @Environment(\.redactionReasons) var redactionReasons
    
    var habit: HabitItem
    
//    let iconColors: [Color] = [Color.primary, Color.red, Color.orange, Color.yellow, Color.green, Color.pink, Color.purple]
    
    let shownDate = Date().adjustedForNightOwl()
    
    var body: some View {
        if redactionReasons == .placeholder {
            ZStack {
                ProgressBar(strokeWidth: 12, progress: 0, color: .black)
                    .background(Circle().stroke(habit.iconColor.opacity(0.2), lineWidth: 12))
                
                Circle()
                    .foregroundColor(Color("systemGray6"))
                    .scaledToFit()
            }
            .padding()
        } else {
            ZStack {
                ProgressBar(strokeWidth: 12, color: habit.iconColor, habit: habit, date: Date().adjustedForNightOwl())
                    .background(Circle().stroke(habit.iconColor.opacity(0.2), lineWidth: 12))
                
                habit.wrappedIcon
                    .resizable()
                    .foregroundColor(habit.iconColor)
                    .aspectRatio(contentMode: .fit)
                    .padding(22)
            }
            .widgetURL(URL(string: "persistent://openHabit/\(habit.id.uuidString)"))
            .padding(22)
        }
    }
}

struct SmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        
        return SingleWidgetView(habit: HabitItem.testHabit)
            .previewLayout(.sizeThatFits)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
