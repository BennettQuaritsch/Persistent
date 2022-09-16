//
//  RoundedBarChartWidgetProvide.swift
//  PersistentWidgetExtension
//
//  Created by Bennett Quaritsch on 29.08.22.
//

import Foundation
import WidgetKit
import SwiftUI
import CoreData

struct RoundedBarChartWidgetProvider: IntentTimelineProvider {
    func getItems() -> [HabitItem] {
        let moc = PersistenceController.shared.container.viewContext
        
        let request = NSFetchRequest<HabitItem>(entityName: "HabitItem")
        let result = try? moc.fetch(request)
        
        if let result = result {
            return result
        }
        return []
    }
    
    func getPurchaseInfo() -> Bool {
        let keychain = KeychainSwift()
        keychain.accessGroup = "PBR8289HNX.keychainGroup"
        
        #if DEBUG
        return true
        #else
        if Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt" {
            return true
        } else {
            return keychain.getBool("isPurchasedIdentifier") ?? false
        }
        #endif
        
//        return keychain.getBool("isPurchasedIdentifier") ?? false
    }
    
    func placeholder(in context: Context) -> RoundedBarChartEntry {
        RoundedBarChartEntry(
            date: Date(),
            habit: getItems().randomElement() ?? HabitItem.testHabit,
            barChartSize: .smallView,
            valuesShown: true,
            purchaseInfo: getPurchaseInfo()
        )
    }
    
    func getSnapshot(for configuration: SelectHabitForBarChartIntent, in context: Context, completion: @escaping (RoundedBarChartEntry) -> Void) {
        let items = getItems()
        
        guard let habit = items.first(where: { $0.id.uuidString == configuration.habit?.identifier }) else { return }
        let barChartSize = configuration.barChartSize
        let valuesShown = configuration.valuesShown as? Bool ?? true
        
        let entry = RoundedBarChartEntry(date: Date(), habit: habit, barChartSize: barChartSize, valuesShown: valuesShown, purchaseInfo: getPurchaseInfo())
        
        completion(entry)
    }
    
    func getTimeline(for configuration: SelectHabitForBarChartIntent, in context: Context, completion: @escaping (Timeline<RoundedBarChartEntry>) -> Void) {
        let items = getItems()
        
        guard let habit = items.first(where: { $0.id.uuidString == configuration.habit?.identifier }) else { return }
        let barChartSize = configuration.barChartSize
        let valuesShown = configuration.valuesShown as? Bool ?? true
        
        var entries: [RoundedBarChartEntry] = []
        
        var date = Date()
        let purchaseInfo = getPurchaseInfo()
        
        for _ in 0 ..< 5 {
            entries.append(RoundedBarChartEntry(date: date, habit: habit, barChartSize: barChartSize, valuesShown: valuesShown, purchaseInfo: purchaseInfo))
            date = date.changeDate(with: Calendar.defaultCalendar, byAdding: .hour, value: 1)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        
        completion(timeline)
    }
}

struct RoundedBarChartEntry: TimelineEntry {
    let date: Date
    let habit: HabitItem
    let barChartSize: BarChartSizeEnum
    let valuesShown: Bool
    let purchaseInfo: Bool
    
    var chartModelPickerSelection: ChartModel.GraphPickerSelectionEnum {
        switch barChartSize {
        case .smallView:
            return .smallView
        case .mediumView:
            return .mediumView
        case .bigView:
            return .bigView
        case .unknown:
            return .smallView
        }
    }
}

struct RoundedBarChartWidget: Widget {
    let kind: String = "RoundedBarChartWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(
            kind: kind,
            intent: SelectHabitForBarChartIntent.self,
            provider: RoundedBarChartWidgetProvider()) { entry in
                RoundedBarChartWidgetView(
                    habit: entry.habit,
                    graphPickerSelection: entry.chartModelPickerSelection,
                    valuesShown: entry.valuesShown,
                    purchaseInfo: entry.purchaseInfo
                )
            }
            .configurationDisplayName("Widget.RoundedBarChart.Name")
            .description("Widget.RoundedBarChart.Description")
            .supportedFamilies([.systemMedium, .accessoryRectangular])
    }
}
