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
    let colors: [SettingsColor] = [
        SettingsColor(color: Color(red: 0.769, green: 0.443, blue: 0.929, opacity: 1.000), name: "Light Purple"),
        SettingsColor(color: Color(red: 0.969, green: 0.475, blue: 0.490, opacity: 1.000), name: "Rose"),
        SettingsColor(color: Color(red: 1.000, green: 0.255, blue: 0.424, opacity: 1.000), name: "Pinkest Pink"),
        SettingsColor(color: Color(red: 1.000, green: 0.294, blue: 0.169, opacity: 1.000), name: "Fire"),
        SettingsColor(color: Color(red: 0.941, green: 0.596, blue: 0.098, opacity: 1.000), name: "Mandarine"),
        SettingsColor(color: Color(red: 0.471, green: 1.000, blue: 0.839, opacity: 1.000), name: "Baby Blue"),
        SettingsColor(color: Color(red: 0.659, green: 1.000, blue: 0.471, opacity: 1.000), name: "Grass")
    ]
    
    @Published var accentColorIndex: Int {
        didSet {
            UserDefaults.standard.set(accentColorIndex, forKey: "accentColorIndex")
            accentColor = colors[accentColorIndex].color
        }
    }
    @Published var accentColor: Color
    
    @Published var syncEnabled: Bool {
        didSet {
            UserDefaults.standard.set(syncEnabled, forKey: "syncEnabled")
        }
    }
    
    init() {
        let index: Int = UserDefaults.standard.object(forKey: "accentColorIndex") as? Int ?? 0
        self.accentColorIndex = index
        self.accentColor = colors[index].color
        
        let syncEnabled: Bool = UserDefaults.standard.bool(forKey: "syncEnabled")
        self.syncEnabled = syncEnabled
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
