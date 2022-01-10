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
                Link("Ionicons for making their icons open source!", destination: url)
                    .padding(5)
            }
            
            if let keychainUrl = URL(string: "https://github.com/jrendel/SwiftKeychainWrapper") {
                Link("KeychainWrapper", destination: keychainUrl)
                    .padding(5)
            }
        }
        #if os(iOS)
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Thanks to...")
        #endif
    }
}

struct AboutPersistentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutPersistentView()
        }
    }
}
