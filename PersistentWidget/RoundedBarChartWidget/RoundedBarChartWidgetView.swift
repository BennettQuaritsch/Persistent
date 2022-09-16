//
//  RoundedBarChartWidgetView.swift
//  PersistentWidgetExtension
//
//  Created by Bennett Quaritsch on 29.08.22.
//

import SwiftUI
//import SwiftKeychainWrapper

struct RoundedBarChartWidgetView: View {
    @Environment(\.widgetFamily) var widgetFamily
    
    let habit: HabitItem
    let graphPickerSelection: ChartModel.GraphPickerSelectionEnum
    let valuesShown: Bool
    let purchaseInfo: Bool
    
    @StateObject var chartModel: ChartModel = .init()
    
    @State private var leadingValuesViewHeight: CGFloat = 10
    
    var body: some View {
        switch widgetFamily {
        case .systemMedium:
            HStack(alignment: .top) {
                if valuesShown {
                    VStack(spacing: 0) {
                        Text("\(NumberFormatter.stringFormattedForHabitTypeShort(value: chartModel.maxValue, habit: habit))")
                        
                        Spacer()
                        
                        Text("0")
                    }
                    .font(.system(.callout, weight: .regular))
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 5)
                    .frame(height: leadingValuesViewHeight)
                }
                
                VStack(spacing: 5) {
                    RoundedBarChartBase(
                        habit: habit,
                        chartModel: chartModel,
                        graphPickerSelection: .constant(graphPickerSelection),
                        valuesShown: .constant(false),
                        rectangleColor: .systemGray6
                    )
                    .onPreferenceChange(RoundedBarChartHeightPreferenceKey.self) { height in
                        leadingValuesViewHeight = height
                    }
                    .onAppear {
                        chartModel.loadBarChart(for: habit, graphSize: graphPickerSelection)
                    }
                    
                    if valuesShown {
                        footerView
                            .foregroundStyle(.secondary)
                            .minimumScaleFactor(0.7)
                            .lineLimit(1)
                    }
                }
            }
            .padding(16)
            .widgetURL(URL(string: "persistent://openHabit/\(habit.id.uuidString)"))
            .modifier(PurchaseInfoOverlay(purchaseInfo: purchaseInfo))
        case .accessoryRectangular:
            VStack(spacing: 5) {
                RoundedBarChartBase(
                    habit: habit,
                    chartModel: chartModel,
                    graphPickerSelection: .constant(graphPickerSelection),
                    valuesShown: .constant(false),
                    rectangleColor: .clear,
                    customSpacing: graphPickerSelection == .bigView ? 6 : 10
                )
                .widgetAccentable()
                .onPreferenceChange(RoundedBarChartHeightPreferenceKey.self) { height in
                    leadingValuesViewHeight = height
                }
                .onAppear {
                    chartModel.loadBarChart(for: habit, graphSize: graphPickerSelection)
                }
                .padding(.horizontal, graphPickerSelection == .bigView ? 3 : 5)
                
                if valuesShown {
                    smallFfooterView
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                }
            }
            .widgetURL(URL(string: "persistent://openHabit/\(habit.id.uuidString)"))
            .modifier(PurchaseInfoOverlay(purchaseInfo: purchaseInfo))
        default:
            EmptyView()
        }
    }
}

extension RoundedBarChartWidgetView {
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
            HStack() {
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
    
    @ViewBuilder var smallFfooterView: some View {
        switch graphPickerSelection {
        case .smallView:
            HStack(spacing: 0) {
                ForEach(chartModel.chartDates, id: \.self) { date in
                    Text(date.formatted(.dateTime.weekday(.short)).trimmingCharacters(in: .punctuationCharacters))
                }
                .frame(maxWidth: .infinity)
            }
        case .mediumView:
            HStack(spacing: 0) {
                ForEach(chartModel.chartDates, id: \.self) { date in
                    Text(date.formatted(.dateTime.week(.defaultDigits)))
                }
                .frame(maxWidth: .infinity)
            }
        case .bigView:
            HStack(spacing: 0) {
                ForEach(chartModel.chartDates, id: \.self) { date in
                    Text(date.formatted(.dateTime.month(.narrow)))
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    struct PurchaseInfoOverlay: ViewModifier {
        let purchaseInfo: Bool
        func body(content: Content) -> some View {
            ZStack {
                content
                
                if !purchaseInfo {
                    Text("Only available with Persistent Premium")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }
}

struct RoundedBarChartWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        RoundedBarChartWidgetView(habit: HabitItem.testHabit, graphPickerSelection: .smallView, valuesShown: true, purchaseInfo: true)
    }
}
