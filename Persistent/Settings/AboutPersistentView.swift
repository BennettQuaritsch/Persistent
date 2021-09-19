//
//  AboutPersistentView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 16.09.21.
//

import SwiftUI

struct AboutPersistentView: View {
    var body: some View {
        List {
            if let url = URL(string: "https://ionic.io/ionicons") {
                Link("Thanks ionicons for making their icons open source!", destination: url)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Thanks to")
    }
}

struct AboutPersistentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutPersistentView()
        }
    }
}
