//
//  RoundedBarChartBase.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 29.08.22.
//

import SwiftUI

struct RoundedBarChartBase: View {
    @Environment(\.parentSizeClass) var parentSizeClass
    
    let habit: HabitItem
    @ObservedObject var chartModel: ChartModel
    
    @Binding var graphPickerSelection: ChartModel.GraphPickerSelectionEnum
    @Binding var valuesShown: Bool
    
    var rectangleColor: Color    
    let customSpacing: Double?
    
    init(
        habit: HabitItem,
        chartModel: ChartModel,
        graphPickerSelection: Binding<ChartModel.GraphPickerSelectionEnum>,
        valuesShown: Binding<Bool>,
        rectangleColor: Color = .systemBackground,
        customSpacing: Double? = nil
    ) {
        self.habit = habit
        self.chartModel = chartModel
        self._graphPickerSelection = graphPickerSelection
        self._valuesShown = valuesShown
        self.rectangleColor = rectangleColor
        self.customSpacing = customSpacing
    }
    
    var spacing: Double {
        if let customSpacing { return customSpacing }
        
        return parentSizeClass == .regular ? 20 : 10
    }
    
    var body: some View {
        GeometryReader { geo in
            HStack(alignment: .bottom, spacing: spacing) {
                // .indices weil sonst die Animation nicht funktioniert
                ForEach(chartModel.chartValues.indices, id: \.self) { index in
                    
                    ZStack(alignment: .bottom) {
                        RoundedRectangle(cornerRadius: parentSizeClass == .regular ? 20 : 10, style: .continuous)
                            .foregroundColor(rectangleColor)
                        
                        RoundedRectangle(cornerRadius: parentSizeClass == .regular ? 20 : 10, style: .continuous)
                            .foregroundColor(habit.iconColor)
                            .frame(height: CGFloat(chartModel.chartValues[index]) / CGFloat(chartModel.maxValue) * geo.size.height)
                    }
                    .overlay(alignment: .bottom) {
                        if graphPickerSelection == .smallView || graphPickerSelection == .mediumView {
                            if valuesShown {
                                Text("\(NumberFormatter.stringFormattedForHabitTypeShort(value: chartModel.chartValues[index], habit: habit))")
                                    .minimumScaleFactor(0.7)
                                    .foregroundStyle(.secondary)
                                    .padding(.bottom, 5)
                                    .transition(Self.smallValuesTransition)
                            }
                        }
                    }
                    
                }
            }
            .preference(key: RoundedBarChartHeightPreferenceKey.self, value: geo.size.height)
            .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
        }
    }
}

extension RoundedBarChartBase {
    static let smallValuesTransition: AnyTransition = .opacity.combined(with: .scale(scale: 0.5)).combined(with: .move(edge: .leading))
}

struct RoundedBarChartHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 100
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


struct RoundedBarChartBase_Previews: PreviewProvider {
    static var previews: some View {
        RoundedBarChartBase(habit: HabitItem.testHabit, chartModel: ChartModel(), graphPickerSelection: .constant(.smallView), valuesShown: .constant(true))
    }
}
