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
                        
                        Text("Settings.About.About.Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown")")
                            .font(.body.weight(.light))
                        
                        Text("Settings.About.About.BuiltBy")
                            .font(.footnote.weight(.light))
                            .padding(.top, 1)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            
            CustomLinkView(url: url, text: "Settings.About.About.Feedback")
                .padding(.vertical, 5)
            
            if let url = URL(string: "https://persistentapp.net/") {
                CustomLinkView(url: url, text: "Settings.About.About.Website")
            }
            
            CustomLinkView(url: URL(string: "https://twitter.com/PersistentApp")!, text: "Settings.About.About.Twitter")
            
            if let url = URL(string: "https://persistentapp.net/termsofuse/") {
                CustomLinkView(url: url, text: "Settings.About.About.TermsOfUse")
            }
            
            if let url = URL(string: "https://persistentapp.net/privacypolicy/") {
                CustomLinkView(url: url, text: "Settings.About.About.PrivacyPolicy")
            }
            
            if let reviewLink = reviewLink {
                CustomLinkView(url: reviewLink, text: "Settings.About.About.Review")
            }
        }
        .buttonStyle(.plain)
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("Settings.About.About")
    }
}

struct AboutAppView_Previews: PreviewProvider {
    static var previews: some View {
        AboutAppView()
    }
}
