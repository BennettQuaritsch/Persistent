//
//  AboutAppView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 03.01.22.
//

import SwiftUI
import StoreKit

struct AboutAppView: View {
    let url = URL(string: "mailto:persistentapp@protonmail.com")!
    var body: some View {
        List {
            Section {
                VStack {
                    Image("persistentLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(minWidth: 100, maxWidth: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                    
                    Text("Persistent")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(3)
                    
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown")")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            
            
            Button("Give Feedback") {
                if UIApplication.shared.canOpenURL(url) {
                    Task {
                        await UIApplication.shared.open(url, options: [:])
                    }
                }
            }
            
            Link("Twitter", destination: URL(string: "https://twitter.com/PersistentApp")!)
            
            Button("Leave a review 😀") {
                if let windowScene = UIApplication.shared.keyWindow?.windowScene { SKStoreReviewController.requestReview(in: windowScene) }
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("About the App")
    }
}

extension UIApplication {
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
}

struct AboutAppView_Previews: PreviewProvider {
    static var previews: some View {
        AboutAppView()
    }
}
