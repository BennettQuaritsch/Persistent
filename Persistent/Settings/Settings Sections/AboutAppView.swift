//
//  AboutAppView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 03.01.22.
//

import SwiftUI
import StoreKit

struct AboutAppView: View {
    let url = URL(string: "mailto:support@persistentapp.net")!
    
    let reviewLink = URL(string: "https://apps.apple.com/app/id1577234546?action=write-review")
    
    var body: some View {
        List {
            Section {
                HStack(spacing: 15) {
                    Image("persistentLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 80, maxWidth: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Persistent")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown")")
                            .font(.body.weight(.light))
                        
                        Text("Built by Bennett Quaritsch")
                            .font(.footnote.weight(.light))
                            .padding(.top, 1)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            
            CustomLinkView(url: url, text: "Feedback, Feature Requests and Bug Reports")
                .padding(.vertical, 5)
            
            if let url = URL(string: "https://persistentapp.net/") {
                CustomLinkView(url: url, text: "Persistent Website")
            }
            
            CustomLinkView(url: URL(string: "https://twitter.com/PersistentApp")!, text: "Persistent Twitter")
            
            if let reviewLink = reviewLink {
                CustomLinkView(url: reviewLink, text: "Leave a review 😀")
            }
        }
        .buttonStyle(.plain)
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("About the App")
    }
}

struct AboutAppView_Previews: PreviewProvider {
    static var previews: some View {
        AboutAppView()
    }
}
