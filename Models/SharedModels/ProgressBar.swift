//
//  TestCircle.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 16.11.21.
//

import SwiftUI

struct ProgressBar: View {
    var progress: CGFloat
    var strokeWidth: CGFloat
    
    init(strokeWidth: CGFloat, progress: CGFloat, color: Color) {
        self.strokeWidth = strokeWidth
        self.progress = progress
        
        #if os(macOS)
        let darker = NSColor(color).usingColorSpace(.sRGB)!.makeColor(componentDelta: -0.2)
        #else
        let darker = UIColor(color).makeColor(componentDelta: -0.2)
        #endif
        
        colors = [Color(darker), color]
    }
    
    var progressDouble: Double {
        Double(progress)
    }
    
    let colors: [Color]
    
    var body: some View {
        ZStack() {
//            Circle()
//                .stroke(Color("systemBackground"), lineWidth: strokeWidth)
            
//            
//            Circle()
//                .stroke(colors.first!.opacity(0.3), lineWidth: strokeWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(AngularGradient(
                    gradient: Gradient(colors: colors),
                    center: .center, angle: .degrees(progress <= 0.95 ? Double(progress) * 360 + 7 : Double(progress) * 360)),
                    style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
            
            HStack {
                Spacer()
                
                Circle()
                    .foregroundColor(colors.last!)
                    .frame(width: strokeWidth, height: strokeWidth)
                    .offset(x: strokeWidth / 2)
            }
            .rotationEffect(.degrees(Double(progress) * 360 - 90))
            .opacity(progressDouble > 0 ? 1 : 0)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// These extensions would of coruse be moved to another file
extension Color {
    static var circleAccentColor   = Color(hex: "#B81258")
    static var circleGradientColor = AngularGradient(gradient: Gradient(colors: [Color(hex: "#E33F84"), Color(hex: "#B81258")]), center: .center)
}

extension Color {
    init(hex: String) {
        let r, g, b: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
                    b = CGFloat((hexNumber & 0x0000ff)) / 255

                    self.init(.displayP3, red: Double(r), green: Double(g), blue: Double(b), opacity: 1)
                    return
                }
            }
        }
        self.init(.displayP3, red: 1, green: 1, blue: 1, opacity: 1)
    }
}


struct TestCircle: View {
    var body: some View {
        ProgressBar(strokeWidth: 50, progress: 0.5, color: Color(hex: "#E33F84"))
    }
}

struct TestCircle_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TestCircle()
                .padding(50)
            .previewLayout(.sizeThatFits)
            
            TestCircle()
                .preferredColorScheme(.dark)
                .padding(50)
                .previewLayout(.sizeThatFits)
        }
    }
}
