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
                CustomLinkView(url: url, text: "Ionicons")
                        .padding(.vertical, 5)
            }
            
            if let keychainUrl = URL(string: "https://github.com/jrendel/SwiftKeychainWrapper") {
                CustomLinkView(url: keychainUrl, text: "KeychainWrapper")
                    .padding(.vertical, 5)
            }
            
            if let syncMonitorUrl = URL(string: "https://github.com/ggruen/CloudKitSyncMonitor") {
                CustomLinkView(url: syncMonitorUrl, text: "CloudKitSyncMonitor")
                    .padding(.vertical, 5)
            }
        }
        .buttonStyle(.plain)
        #if os(iOS)
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Thanks to...")
        #endif
    }
}

struct CustomLinkView: View {
    let url: URL
    let text: String
    
    var body: some View {
        Link(destination: url) {
            HStack {
                Text(text)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.body.bold())
                    .imageScale(.small)
                    .foregroundStyle(.tertiary)
            }
            .contentShape(Rectangle())
        }
    }
}

struct AboutPersistentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutPersistentView()
                
        }
        .preferredColorScheme(.dark)
    }
}
