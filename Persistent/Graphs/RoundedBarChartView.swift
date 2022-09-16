//
//  RoundedBarChart.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 16.08.22.
//

import SwiftUI

struct RoundedBarChartView: View {
    @Environment(\.parentSizeClass) var parentSizeClass
    
    @ObservedObject var chartModel: ChartModel
    
    let habit: HabitItem
    
    @State private var valuesShown: Bool = false
    
    @State private var graphPickerSelection: ChartModel.GraphPickerSelectionEnum = .smallView
    
    @State private var leadingValuesViewHeight: CGFloat = 10
    
    var spacing: Double {
//        if graphPickerSelection == .smallView {
//            return parentSizeClass == .regular ? 20 : 10
//        } else {
//            return parentSizeClass == .regular ? 10 : 5
//        }
        return parentSizeClass == .regular ? 20 : 10
    }
    
    @ViewBuilder var footerView: some View {
        switch graphPickerSelection {
        case .smallView:
            HStack {
                ForEach(chartModel.chartDates, id: \.self) { date in
                    Text(date.formatted(.dateTime.weekday(.short)).trimmingCharacters(in: .punctuationCharacters))
                }
                .frame(maxWidth: .infinity)
            }
        case .mediumView:
            HStack {
                ForEach(chartModel.chartDates, id: \.self) { date in
                    Text(date.formatted(.dateTime.week(.twoDigits)))
                }
                .frame(maxWidth: .infinity)
            }
        case .bigView:
            HStack {
                ForEach(chartModel.chartDates, id: \.self) { date in
                    Text(date.formatted(.dateTime.month(.narrow)))
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
    
    var body: some View {
        VStack {
            Picker("Statistics.Picker.Header", selection: $graphPickerSelection) {
                Text("Statistics.Picker.Days").tag(ChartModel.GraphPickerSelectionEnum.smallView)
                Text("Statistics.Picker.Week").tag(ChartModel.GraphPickerSelectionEnum.mediumView)
                Text("Statistics.Picker.Months").tag(ChartModel.GraphPickerSelectionEnum.bigView)
            }
            .pickerStyle(.segmented)
            .onChange(of: graphPickerSelection) { selection in
                valuesShown = false
                chartModel.loadBarChart(for: habit, graphSize: selection)
            }
            
            Spacer()
                .frame(height: parentSizeClass == .regular ? 20 : 10)
            
            HStack(alignment: .top) {
                if valuesShown {
                    VStack {
                        Text("\(NumberFormatter.stringFormattedForHabitTypeShort(value: chartModel.maxValue, habit: habit))")
//                HabitValueTypes.amountFromRawAmount(for: chartModel.maxValue, valueType: habit.valueTypeEnum)
//                        Spacer()
//                        
//                        Text("\(NumberFormatter.stringFormattedForHabitTypeShort(value: chartModel.maxValue / 2, habit: habit))")
                        
                        Spacer()
                        
                        Text("0")
                    }
                    .font(.system(.callout, weight: .regular))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 5)
                    .frame(height: leadingValuesViewHeight)
                }
                
                VStack {
                    RoundedBarChartBase(habit: habit, chartModel: chartModel, graphPickerSelection: $graphPickerSelection, valuesShown: $valuesShown)
                        .onPreferenceChange(RoundedBarChartHeightPreferenceKey.self) { height in
                            leadingValuesViewHeight = height
                        }
                        .onTapGesture {
//                            if graphPickerSelection == .smallView || graphPickerSelection == .mediumView {
//                                
//                            }
                            withAnimation(.easeOut(duration: 0.1)) {
                                valuesShown.toggle()
                            }
                        }
                    
                    footerView
                        .foregroundStyle(.secondary)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                }
            }
        }
        .onAppear {
            chartModel.loadBarChart(for: habit, graphSize: graphPickerSelection)
        }
        
    }
}

struct RoundedBarChartView_Previews: PreviewProvider {
    static var previews: some View {
        RoundedBarChartView(chartModel: ChartModel(), habit: HabitItem.testHabit)
    }
}
