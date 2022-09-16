//
//  DecimalExtension.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 12.04.22.
//

import Foundation
import SwiftUI

extension Decimal {
    var cgFloatValue: CGFloat {
        return CGFloat(NSDecimalNumber(decimal: self).doubleValue)
    }
    
    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
    
    var intValue: Int {
        return NSDecimalNumber(decimal: self).intValue
    }
}
