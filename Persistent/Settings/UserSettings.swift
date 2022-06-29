//
//  UserSettings.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 14.06.21.
//

import Foundation
import SwiftUI
import Combine

struct SettingsColor {
    var color: Color
    var name: String
}

class UserSettings: ObservableObject {
    let accentColorNames: [String] = [
        "Persistent",
        "Fire",
        "Rose",
        "Violet",
        "Waves",
        "Deep Sea",
        "Grass",
        "Sun"
    ]
    
    enum ThemeSelectionEnum: String, CaseIterable, Hashable {
        case automatic
        case light
        case dark
        
        var name: String {
            self.rawValue
        }
        
        var shownName: String {
            switch self {
            case .automatic:
                return "Automatic"
            case .light:
                return "Light Mode"
            case .dark:
                return "Dark Mode"
            }
        }
        
        var relevantColorScheme: ColorScheme? {
            switch self {
            case .automatic:
                return nil
            case .light:
                return .light
            case .dark:
                return.dark
            }
        }
        
        init(_ name: String?) {
            switch name {
            case "light":
                self = .light
            case "dark":
                self = .dark
            default:
                self = .automatic
            }
        }
    }
    
    @Published var accentColorName: String {
        didSet {
            UserDefaults.standard.set(accentColorName, forKey: "accentColorName")
            accentColor = Color(accentColorName)
        }
    }
    @Published var accentColor: Color
    
    @Published var syncDisabled: Bool {
        didSet {
            UserDefaults.standard.set(syncDisabled, forKey: "syncDisabled")
        }
    }
    
    @Published var leftHandedInterface: Bool {
        didSet {
            UserDefaults.standard.set(leftHandedInterface, forKey: UserSettings.userDefaultsLeftHandedInterfaceString)
        }
    }
    static let userDefaultsLeftHandedInterfaceString: String = "leftHandedInterface"
    
    @Published var simplerListCellColor: Bool {
        didSet {
            UserDefaults.standard.set(simplerListCellColor, forKey: UserSettings.simplerListCellColorKeyString)
        }
    }
    static let simplerListCellColorKeyString: String = "simplerListCellColor"
    
    /// Night Mode hour settings variable
    @Published var nightOwlHourSelection: Int {
        didSet {
            let userDefaults = UserDefaults(suiteName: "group.persistentData") ?? UserDefaults.standard
            userDefaults.set(nightOwlHourSelection, forKey: UserSettings.nightOwlHourSelectionKeyString)
        }
    }
    static let nightOwlHourSelectionKeyString: String = "nightOwlHourSelection"
    
    @Published var themeSelection: ThemeSelectionEnum {
        didSet {
            UserDefaults.standard.set(themeSelection.name, forKey: UserSettings.themeSelectionKeyString)
        }
    }
    static let themeSelectionKeyString: String = "themeSelection"
    
    init() {
        let name: String = UserDefaults.standard.object(forKey: "accentColorName") as? String ?? "Persistent"
        self.accentColorName = name
        self.accentColor = Color(name)
        
        let syncDisabled: Bool = UserDefaults.standard.bool(forKey: "syncDisabled")
        self.syncDisabled = syncDisabled
        
        self.leftHandedInterface = UserDefaults.standard.bool(forKey: UserSettings.userDefaultsLeftHandedInterfaceString)
        
        self.simplerListCellColor = UserDefaults.standard.bool(forKey: UserSettings.simplerListCellColorKeyString)
        
        let userDefaults = UserDefaults(suiteName: "group.persistentData") ?? UserDefaults.standard
        self.nightOwlHourSelection = userDefaults.integer(forKey: UserSettings.nightOwlHourSelectionKeyString)
        
        let themeSelectionString = UserDefaults.standard.string(forKey: UserSettings.themeSelectionKeyString)
        self.themeSelection = .init(themeSelectionString)
    }
}

private struct SettingsEnvironmentKey: EnvironmentKey {
    static let defaultValue: UserSettings = UserSettings()
}


extension EnvironmentValues {
    var settingsEnvironment: UserSettings {
        get { self[SettingsEnvironmentKey.self] }
        set { self[SettingsEnvironmentKey.self] = newValue }
    }
}
