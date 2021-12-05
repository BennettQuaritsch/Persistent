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
