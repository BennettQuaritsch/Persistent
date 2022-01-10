//
//  NewProgressBar.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 14.08.21.
//

import SwiftUI
//import DynamicColor
#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

#if os(macOS)
extension NSColor {
    func makeColor(componentDelta: CGFloat) -> NSColor {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Extract r,g,b,a components from the
        // current UIColor
        getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )
        
        
        // Create a new UIColor modifying each component
        // by componentDelta, making the new UIColor either
        // lighter or darker.
        return NSColor(
            red: add(componentDelta, toComponent: red),
            green: add(componentDelta, toComponent: green),
            blue: add(componentDelta, toComponent: blue),
            alpha: alpha
        )
    }
    
    // Add value to component ensuring the result is
    // between 0 and 1
    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        return max(0, min(1, toComponent + value))
    }
}
#endif

#if os(iOS) || os(watchOS)
extension UIColor {
    func makeColor(componentDelta: CGFloat) -> UIColor {
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        var alpha: CGFloat = 0
        
        // Extract r,g,b,a components from the
        // current UIColor
        getRed(
            &red,
            green: &green,
            blue: &blue,
            alpha: &alpha
        )
        
        // Create a new UIColor modifying each component
        // by componentDelta, making the new UIColor either
        // lighter or darker.
        return UIColor(
            red: add(componentDelta, toComponent: red),
            green: add(componentDelta, toComponent: green),
            blue: add(componentDelta, toComponent: blue),
            alpha: alpha
        )
    }
    
    // Add value to component ensuring the result is
    // between 0 and 1
    private func add(_ value: CGFloat, toComponent: CGFloat) -> CGFloat {
        return max(0, min(1, toComponent + value))
    }
}
#endif

//struct ProgressBar: View {
//    let strokeWidth: CGFloat
//    var progress: CGFloat
//    let shadowRadius: CGFloat
//    
//    init(strokeWidth: CGFloat, progress: CGFloat, color: Color, shadowRadius: CGFloat = 0) {
//        self.strokeWidth = strokeWidth
//        self.progress = progress
//        self.shadowRadius = shadowRadius
//        
//        #if os(macOS)
//        let darker = NSColor(color).usingColorSpace(.sRGB)!.makeColor(componentDelta: -0.2)
//        #else
//        let darker = UIColor(color).makeColor(componentDelta: -0.2)
//        #endif
//        
//        colors = [Color(darker), color]
//    }
//    
//    let colors: [Color]
//    
//    var leftoverProgress: CGFloat {
//        progress.truncatingRemainder(dividingBy: 1)
//    }
//    
//    var progressDouble: Double {
//        Double(progress)
//    }
//    
//    var fromValue: CGFloat {
//        var value = leftoverProgress - 0.05
//        if value < 0 {
//            value = 0
//        }
//        return value
//    }
//    
//    func radius(geo: GeometryProxy) -> CGFloat {
//        return min(geo.size.height, geo.size.width)
//    }
//    let alternativeColors: [Color] = [.blue, .green]
//    
//    var body: some View {
//        GeometryReader { geo in
//            ZStack {
//                Circle()
//                    .stroke(Color("tertiaryGroupedBackground"), lineWidth: strokeWidth)
//                
//                Circle()
//                    .trim(from: 0.0, to: progress)
//                    .stroke(AngularGradient(gradient: Gradient(colors: colors), center: .center, angle: .degrees(progress <= 0.95 ? progressDouble * 360 + 7 : progressDouble * 360)), style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round))
//                    .rotationEffect(.degrees(-90))
//                    .frame(width: radius(geo: geo))
//                    //.shadow(color: .black.opacity(0.4), radius: shadowRadius)
//                    
//                    //.opacity(progress >= 1 ? 0 : 1)
//                
////                Circle()
////                    .trim(from: 0.0, to: progress)
////                    .stroke(AngularGradient(gradient: Gradient(colors: alternativeColors), center: .center, angle: .degrees(progress <= 0.95 ? progressDouble * 360 + 7 : progressDouble * 360)), style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round))
////                    .rotationEffect(.degrees(-90))
////                    .frame(width: radius(geo: geo))
////                    .shadow(color: .black.opacity(0.4), radius: 5)
////                    .opacity(progress >= 1 ? 1 : 0)
//                
//                Circle()
//                    .fill(colors.last!)
//                    .frame(width: strokeWidth)
//                    .offset(y: -radius(geo: geo) / 2)
//                    .shadow(color: progress > 0.95 ? Color.black.opacity(0.05): Color.clear, radius: 3, x: 4, y: 0)
//                    .rotationEffect(.degrees(progressDouble * 360))
//                    .opacity(progress > 0 ? 1 : 0)
//                    
//            }
//            .frame(width: geo.size.width, height: geo.size.height)
//        }
//    }
//}
//
//struct ProgressBar_Previews: PreviewProvider {
//    static var previews: some View {
//        ProgressBar(strokeWidth: 30, progress: 0.5, color: .red, shadowRadius: 5)
//    }
//}
