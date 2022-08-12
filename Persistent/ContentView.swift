//
//  TempContentView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 24.05.21.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \HabitTag.name, ascending: true)], animation: .easeInOut) var tags: FetchedResults<HabitTag>
    
    var body: some View {
        if horizontalSizeClass == .compact {
            iPhoneView()
                .environment(\.parentSizeClass, horizontalSizeClass)
        } else if horizontalSizeClass == .regular {
            AppSidebarNavigation(tags: tags.map { $0 })
                .environment(\.parentSizeClass, horizontalSizeClass)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
