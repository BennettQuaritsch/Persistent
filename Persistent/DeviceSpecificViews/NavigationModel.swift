//
//  NavigationModel.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 11.07.22.
//

import Foundation
import SwiftUI

class NavigationModel: ObservableObject {
    static let userDefaultsKey: String = "NavigationPathUserDefaultsKey"
    @Published var path: NavigationPath
    
    static func readSerializedData() -> Data? {
        let userDefaults = UserDefaults(suiteName: "group.persistentData") ?? UserDefaults.standard
        
        return userDefaults.data(forKey: Self.userDefaultsKey)
    }
    
    static func storeSerializedData(_ data: Data) {
        let userDefaults = UserDefaults(suiteName: "group.persistentData") ?? UserDefaults.standard
        
        userDefaults.set(data, forKey: Self.userDefaultsKey)
    }
    
    init() {
        if let data = Self.readSerializedData() {
            do {
                let representation = try JSONDecoder().decode(NavigationPath.CodableRepresentation.self, from: data)
                self.path = NavigationPath(representation)
            } catch {
                self.path = NavigationPath()
            }
        } else {
            self.path = NavigationPath()
        }
    }
    
    func save() {
        guard let representation = path.codable else { return }
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(representation)
            Self.storeSerializedData(data)
        } catch {
            
        }
    }
}
