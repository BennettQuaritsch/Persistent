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
                    .background(Circle().stroke(habit?.iconColor.opacity(0.2) ?? Color.primary.opacity(0.2), lineWidth: 10))
                
                Circle()
                    .foregroundColor(Color("systemGray6"))
                    .scaledToFit()
            }
            .padding()
        } else {
            if let habit = habit {
                ZStack {
                    ProgressBar(strokeWidth: 10, color: habit.iconColor, habit: habit, date: Date().adjustedForNightOwl())
                        .background(Circle().stroke(habit.iconColor.opacity(0.2), lineWidth: 10))
                    
                    if habit.iconName != nil {
                        Image(habit.iconName!)
                            .resizable()
                            .foregroundColor(habit.iconColor)
                            .aspectRatio(contentMode: .fit)
                            .padding(22)
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
        
        return SmallWidgetView(habit: HabitItem.testHabit)
            .previewLayout(.sizeThatFits)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
