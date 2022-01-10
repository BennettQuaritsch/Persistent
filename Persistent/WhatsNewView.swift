//
//  WhatsNewView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 04.01.22.
//

import SwiftUI

struct WelcomeView: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    @Environment(\.dismiss) var dismiss
    
    let welcomeItems: [PremiumContent] = [
        .init(title: "Add habit", description: "Add a habit by pressing the plus button in the lower right (or left) corner.", systemImageName: "plus"),
        .init(title: "Detailed view", description: "Click on the habits in the list to view them in detail.", systemImageName: "magnifyingglass"),
        .init(title: "Context menus", description: "Long press on a habit in the list to see a context menu.", systemImageName: "ellipsis.circle")
    ]
    var body: some View {
        VStack {
            Spacer()
                .frame(minHeight: 20, maxHeight: 60)
                .layoutPriority(1)
            
            Text("Welcome to Persistent")
                
                .font(.system(size: 45))
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)
                .layoutPriority(2)
            
            VStack(alignment: .leading, spacing: 30) {
                ForEach(welcomeItems, id: \.self) { content in
                    HStack(spacing: 0) {
                        Image(systemName: content.systemImageName)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.accentColor)
                        #if os(iOS)
                            .frame(width: 35)
                            .padding(.trailing)
                        #endif
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(content.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(content.description)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .layoutPriority(1)
            
            VStack {
                Text("Explore the rest yourself!")
                    .padding(.bottom, 5)
                
                Text("Have fun!")
            }
            .font(.title3.weight(.semibold))
            .padding()
            .layoutPriority(1)
            
            Spacer(minLength: 30)
                .layoutPriority(0)
            
            Button {
                dismiss()
            } label: {
                Text("Get started")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.bottom)
            
        }
        .padding()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WelcomeView()
            
//            WhatsNewView()
//                .previewDevice("iPhone 8")
            
//            WhatsNewView()
//                .previewDevice("iPhone 13 mini")
//            WhatsNewView()
//                .previewDevice("iPad Pro (12.9-inch) (5th generation)")
        }
    }
}
