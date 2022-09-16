//
//  ShareProgressCircleView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 25.08.22.
//

import SwiftUI

struct ShareProgressCircleView: View {
    let habit: HabitItem
    let date: Date
    
    var body: some View {
        VStack(spacing: 20) {
            Text(habit.habitName)
                .font(.system(size: 80, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text(String.localizedStringWithFormat(NSLocalizedString("DetailView.GoalString %@ %@", comment: ""), habit.amountToDoString(), NSLocalizedString(habit.resetIntervalEnum.nounLocalizedStringKey, comment: "")))
                .font(.system(size: 50, weight: .medium))
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            ZStack {
                ProgressBar(strokeWidth: 80, color: habit.iconColor, habit: habit)
                    .background(
                        Circle()
                            .stroke(habit.iconColor.opacity(0.2), lineWidth: 80)
                    )
                
                Text("\(habit.relevantCountText())")
                    .font(.system(size: 120, weight: .heavy, design: .rounded))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: 600)
            }
            .padding(.vertical, 70)
            
            Text(String.localizedStringWithFormat(NSLocalizedString("Share.ProgressCircle.Date.Text %@", comment: ""), date.formatted(.dateTime.day().month().year())))
                .font(.system(size: 50, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(100)
        .frame(width: 1000, height: 1500)
        .background(Color.systemBackground, ignoresSafeAreaEdges: .all)
    }
}

struct ShareProgressCircleView_Previews: PreviewProvider {
    static var previews: some View {
        ShareProgressCircleView(habit: HabitItem.testHabit, date: Date())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .previewLayout(.sizeThatFits)
    }
}
