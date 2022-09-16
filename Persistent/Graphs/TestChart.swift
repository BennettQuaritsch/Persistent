//
//  TestChart.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 16.08.22.
//

import SwiftUI
import Charts

struct TestChart: View {
    @StateObject var chartModel = ChartModel()
    
    let habit: HabitItem
    
    var body: some View {
        Chart {
            ForEach(chartModel.chartDates, id: \.self) { date in
                BarMark(x: .value("number", date.formatted(.dateTime.weekday(.short))), y: .value("value", habit.relevantCountForType(date)))
            }
        }
        .frame(height: 300)
        .padding()
        .onAppear {
//            chartModel.loadBarChart(for: habit, graphSize: .mediumView)
        }
    }
}

struct TestChart_Previews: PreviewProvider {
    static var previews: some View {
        TestChart(habit: HabitItem.testHabit)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
