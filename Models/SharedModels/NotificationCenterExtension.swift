//
//  NotificationCenterExtension.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 03.08.22.
//

import Foundation
import UserNotifications

extension UNUserNotificationCenter {
    static let standardAddActionIdentifier = "STANDARD_ADD_ACTION"
    static let standardAddAction = UNNotificationAction(identifier: standardAddActionIdentifier, title: "Add standard amount", options: [], icon: UNNotificationActionIcon(systemImageName: "plus"))
    
    static let habitNotificationCategoryIdentifier = "HABIT_ NOTIFICATION_CATEGORY"
    static let habitNotificationCategory = UNNotificationCategory(identifier: habitNotificationCategoryIdentifier, actions: [standardAddAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
}
