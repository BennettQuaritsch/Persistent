//
//  PersistentApp.swift
//  PersistentWatch WatchKit Extension
//
//  Created by Bennett Quaritsch on 06.01.22.
//

import SwiftUI

@main
struct PersistentApp: App {
    let persistenceController = PersistenceController.shared
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
