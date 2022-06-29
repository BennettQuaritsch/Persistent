//
//  Vibrations.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 06.01.22.
//

import Foundation
import UIKit

func errorVibration() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.error)
}

func warningVibration() {
    let generator = UINotificationFeedbackGenerator()
    generator.notificationOccurred(.warning)
}

func selectionChangedVibration() {
    let generator = UISelectionFeedbackGenerator()
    generator.selectionChanged()
}
