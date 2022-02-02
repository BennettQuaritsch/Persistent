//
//  ChangeAppIconViewModel.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 12.11.21.
//

import Foundation
import SwiftUI

class ChangeAppIconViewModel: ObservableObject {
    public enum CustomAppIcons: String, CaseIterable, Hashable {
        case classic, zeroEightFifteen, blush, deepSea, night, blackout
        
        var iconName: String {
            switch self {
            case .classic:
                return "Classic"
            case .zeroEightFifteen:
                return "08-15"
            case .blush:
                return "Blush"
            case .deepSea:
                return "Deep Sea"
            case .night:
                return "Night"
            case .blackout:
                return "Blackout"
            }
        }
        
        var fileName: String? {
            switch self {
            case .classic:
                return nil
            case .zeroEightFifteen:
                return "08-15"
            case .blush:
                return "Blush"
            case .deepSea:
                return "Deep-Sea"
            case .night:
                return "Night"
            case .blackout:
                return "Blackout"
            }
        }
        
        var image: Image {
            switch self {
            case .classic:
                return Image("Classic-AppIcon")
            case .zeroEightFifteen:
                return Image("08-15-AppIcon")
            case .blush:
                return Image("Blush-AppIcon")
            case .deepSea:
                return Image("Deep-Sea-AppIcon")
            case .night:
                return Image("Night-AppIcon")
            case .blackout:
                return Image("Blackout-AppIcon")
            }
        }
    }
    
    @MainActor func setAppIcon(_ name: String?) async {
        do {
            try await UIApplication.shared.setAlternateIconName(name)
        } catch {
            print("Setting Icon went wrong: \(error.localizedDescription)")
        }
    }
}
