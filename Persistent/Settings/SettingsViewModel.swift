//
//  SettingsViewViewModel.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 22.12.21.
//

import Foundation

class SettingsViewModel: ObservableObject {
    init() {
        if let weekdaySelectionEnumData = UserDefaults.standard.object(forKey: Calendar.FirstWeekdayEnum.userDefaultsString) as? Data {
            let decoder = JSONDecoder()
            if let decodedWeekdaySelection = try? decoder.decode(Calendar.FirstWeekdayEnum.self, from: weekdaySelectionEnumData) {
                self.firstWeekdaySelection = decodedWeekdaySelection
            } else {
                self.firstWeekdaySelection = .monday
            }
        } else {
            self.firstWeekdaySelection = .monday
        }
    }
    
    @Published var firstWeekdaySelection: Calendar.FirstWeekdayEnum {
        didSet {
            let encoder = JSONEncoder()
            if let encodedWeekdaySelection = try? encoder.encode(firstWeekdaySelection) {
                UserDefaults.standard.set(encodedWeekdaySelection, forKey: Calendar.FirstWeekdayEnum.userDefaultsString)
            }
        }
    }
    
    
}
