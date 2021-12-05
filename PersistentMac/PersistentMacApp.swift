//
//  PersistentMacApp.swift
//  PersistentMac
//
//  Created by Bennett Quaritsch on 23.09.21.
//

import SwiftUI

@main
struct PersistentMacApp: App {
    let persistenceController = PersistenceController.shared
    
    @StateObject var settings = UserSettings()
    @StateObject var storeManager = StoreManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(storeManager)
                .environmentObject(settings)
                .accentColor(settings.accentColor)
                .task {
                    await storeManager.getEntitlements()
                }
                .frame(minWidth: 200, minHeight: 100)
        }
        .commands {
            SidebarCommands()
        }
    }
}
