//
//  TempContentView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 24.05.21.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
//        if horizontalSizeClass == .compact {
//            TabView {
//                iPhoneView()
//                    .tabItem {
//                        Label("Habits", systemImage: "checkmark.circle.fill")
//                }
//
//                SettingsView()
//                    .tabItem {
//                        Label("Settings", systemImage: "gear")
//                    }
//            }
//        } else if horizontalSizeClass == .regular {
//            IPadView()
//        }
        
        TabView {
            iPhoneView()
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle.fill")
            }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
