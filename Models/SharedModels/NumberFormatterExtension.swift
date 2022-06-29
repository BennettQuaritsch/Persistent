//
//  NumberFormatterExtension.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 08.04.22.
//

import Foundation

extension NumberFormatter {
    static var habitValueNumberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 3
        return formatter
    }
    
    static func stringFormattedForHabitTypeShort(value: Int, habit: HabitItem) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 1
//        formatter.roundingMode = .up
        
        let double = Double(value)
        
        switch habit.valueTypeEnum {
        case .volumeLitres:
            return formatter.string(from: (double / 1000) as NSNumber) ?? "1"
        case .timeMinutes:
            return formatter.string(from: (double / 60) as NSNumber) ?? "1"
        case .timeHours:
            return formatter.string(from: (double / 3600) as NSNumber) ?? "1"
        default:
            return formatter.string(from: double as NSNumber) ?? "1"
        }
    }
}
