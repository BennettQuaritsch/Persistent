//
//  AppDelegate.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 23.12.21.
//

import Foundation
import UIKit
import Combine
import CoreData

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        print("launched")
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) async -> UIBackgroundFetchResult {
        print("test")
        return .noData
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        print("test")
        return.badge
    }
}

class SyncMonitor {
    /// Where we store Combine cancellables for publishers we're listening to, e.g. NSPersistentCloudKitContainer's notifications.
    fileprivate var disposables = Set<AnyCancellable>()

    init() {
        NotificationCenter.default.publisher(for: NSPersistentCloudKitContainer.eventChangedNotification)
            .sink(receiveValue: { notification in
                if let cloudEvent = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey]
                    as? NSPersistentCloudKitContainer.Event {
                    // NSPersistentCloudKitContainer sends a notification when an event starts, and another when it
                    // ends. If it has an endDate, it means the event finished.
                    if cloudEvent.endDate == nil {
                        print("Starting an event...") // You could check the type, but I'm trying to keep this brief.
                    } else {
                        switch cloudEvent.type {
                        case .setup:
                            print("Setup finished!")
                        case .import:
                            print("An import finished!")
                        case .export:
                            print("An export finished!")
                        @unknown default:
                            assertionFailure("NSPersistentCloudKitContainer added a new event type.")
                        }

                        if cloudEvent.succeeded {
                            print("And it succeeded!")
                        } else {
                            print("But it failed!")
                        }

                        if let error = cloudEvent.error {
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                }
            })
            .store(in: &disposables)
    }
}
