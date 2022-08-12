//
//  File.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 19.07.22.
//

import Foundation
import SwiftUI

struct ContinuousRoundedTextFieldStyle: TextFieldStyle {
    let backgroundColor: Color
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        ZStack {
            configuration
                .padding(10)
                .background(backgroundColor, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
    }
}

extension TextFieldStyle where Self == ContinuousRoundedTextFieldStyle {
    static func continuousRounded(_ backgroundColor: Color) -> ContinuousRoundedTextFieldStyle {
        ContinuousRoundedTextFieldStyle(backgroundColor: backgroundColor)
        
    }
}
