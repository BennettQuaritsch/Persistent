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
            HabitCompletionGraph(viewModel: HabitBarChartViewModel(habit: habit), headerActivated: false, backgroundColor: .systemGray5)
                .padding(10)
        }
    }
}

struct MediumGraphWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        return MediumGraphWidgetView(habit: HabitItem.testHabit)
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
