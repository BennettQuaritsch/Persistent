//
//  DateNightOwlExtension.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 01.02.22.
//

import Foundation

extension Date {
    func adjustedForNightOwl() -> Date {
        let userDefaults = UserDefaults(suiteName: "group.persistentData") ?? UserDefaults.standard
        let nightOwlInt = userDefaults.integer(forKey: UserSettings.nightOwlHourSelectionKeyString)
        
        let cal = Calendar.defaultCalendar
        
        guard let adjustedDate = cal.date(byAdding: .hour, value: -nightOwlInt, to: self) else { return self }
        
        return adjustedDate
    }
}
