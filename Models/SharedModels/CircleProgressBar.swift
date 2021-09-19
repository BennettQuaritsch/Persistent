//
//  CircleProgressBar.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 20.06.21.
//

import Foundation
import SwiftUI

struct CircleProgressBar: View {
    @Environment(\.colorScheme) var colorScheme
    
    func returnRadius(geometry: GeometryProxy) -> CGFloat {
        let minimum: CGFloat = min(geometry.size.width, geometry.size.height)
        let radius: CGFloat = minimum / 2
        return radius
    }
    
    let progress: CGFloat
    let strokeWidth: CGFloat
    
    let colors: [Color] = [Color(red: 0 / 255, green: 159 / 255, blue: 255 / 255), Color(red: 236 / 255, green: 47 / 255, blue: 75 / 255)]
    
    let completeColors: [Color] = [Color(red: 0 / 255, green: 159 / 255, blue: 255 / 255), Color(red: 50 / 255, green: 222 / 255, blue: 75 / 255)]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Circle()
                    .stroke(lineWidth: strokeWidth)
                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                
                CircleProgress(progress: progress, radius: returnRadius(geometry: geometry))
                    .stroke(style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                    .fill(AngularGradient(gradient: Gradient(colors: completeColors), center: .center, angle: .degrees(Double(progress) * 360)))
                    .shadow(color: Color.black.opacity(0.2), radius: 3)
                
                CircleProgress(progress: progress, radius: returnRadius(geometry: geometry))
                    .stroke(style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round))
                    .fill(AngularGradient(gradient: Gradient(colors: colors), center: .center, angle: .degrees(Double(progress) * 360)))
                    .shadow(color: Color.black.opacity(0.2), radius: 3)
                    .opacity(progress >= 1 ? 0 : 1)
                
                CircleProgressOverlay(progress: progress, radius: returnRadius(geometry: geometry), size: strokeWidth)
                    .fill(progress >= 1 ? completeColors.last ?? Color.green : colors.last ?? Color.red)
                    .shadow(color: Color.black.opacity(0.1),radius: 4, x: cos(progress * 360 * CGFloat.pi / 180 + 90) * 6, y: sin(progress * 360 * CGFloat.pi / 180 + 90) * 6)
                
            }
            .rotationEffect(.degrees(270))
        }
    }
}

struct CircleProgress: Shape {
    var animatableData: CGFloat {
        get { progress }
        set { self.progress = newValue }
    }
    
    var progress: CGFloat
    var radius: CGFloat
    
    var startAngle: Angle {
        if progress <= 1 {
            return .degrees(0)
        } else {
            return .degrees(Double(progress) * 360 - 360)
        }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: radius, startAngle: startAngle, endAngle: .degrees(Double(progress) * 360), clockwise: false)
        
        return path
    }
}

struct CircleProgressOverlay: Shape {
    var animatableData: CGFloat {
        get { progress }
        set { self.progress = newValue }
    }
    
    var progress: CGFloat
    var radius: CGFloat
    let size: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let origin = CGPoint(x: cos(progress * 360 * CGFloat.pi / 180) * radius, y: sin(progress * 360 * CGFloat.pi / 180) * radius)
        let relativeOrigin = CGPoint(x: rect.midX + origin.x, y: rect.midY + origin.y)
        
        if progress != 0 {
            path.addEllipse(in: CGRect(x: relativeOrigin.x - size / 2, y: relativeOrigin.y - size / 2, width: size, height: size))
        }
        
        return path
    }
}
