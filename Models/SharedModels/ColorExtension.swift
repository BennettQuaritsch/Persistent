//
//  ColorExtension.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 23.09.21.
//

import Foundation
import SwiftUI

extension Color {
    static let allColors = [habitColors.red]
    
    static let habitColors = HabitColors()
    
    struct HabitColors {
        let red = Color("red")
    }
}

extension Color {
    #if os(iOS)
    static let systemGroupedBackground = Self.init("systemGroupedBackground")
    static let secondarySystemGroupedBackground = Self.init("secondarySystemGroupedBackground")
    static let tertiaryGroupedBackground = Self.init("tertiaryGroupedBackground")
    static let systemBackground: Color = Self.init(uiColor: .systemBackground)
    static let systemGray6: Color = Self.init("systemGray6")
    static let systemGray5: Color = Self.init("systemGray5")
    static let systemGray4: Color = Self.init("systemGray4")
    #endif
}

extension Color {
    func makeColor(by value: Double) -> Color {
        #if os(macOS)
        return Color(NSColor(self).usingColorSpace(.sRGB)!.makeColor(componentDelta: value))
        #else
        return Color(UIColor(self).makeColor(componentDelta: value))
        #endif
    }
}
