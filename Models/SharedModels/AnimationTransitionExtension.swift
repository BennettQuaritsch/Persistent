//
//  AnimationTransitionExtension.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 20.05.22.
//

import SwiftUI

extension Animation {
    static let standardSpringAnimation: Animation = .spring(response: 0.25, dampingFraction: 0.6, blendDuration: 1)
}

extension AnyTransition {
    static let popUpScaleTransition: AnyTransition = .asymmetric(
        insertion: .scale(scale: 0.4)
            .animation(.standardSpringAnimation),
        removal: .scale(scale: 0.4)
            .animation(.easeIn(duration: 0.10)))
            .combined(with: .opacity).animation(.easeIn(duration: 0.10))
}
