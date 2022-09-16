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
        
        let double = HabitValueTypes.amountFromRawAmount(for: value, valueType: habit.valueTypeEnum)
        
        return formatter.string(from: double as NSNumber) ?? "1"
    }
}
