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
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func applicationSignificantTimeChange(_ application: UIApplication) {
        return
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("HEYHO")
        let moc = PersistenceController.shared.container.viewContext
        let request = HabitItem.fetchRequest()
        
        var habits: [HabitItem]
        
        do {
            habits = try moc.fetch(request)
        } catch {
            habits = []
        }
        
        let userInfo = response.notification.request.content.userInfo
        guard let habitID = UUID(uuidString: userInfo["HABIT_ID"] as! String) else { return }
        
        guard let habit = habits.first(where: { $0.id == habitID }) else { return }
        
        switch response.actionIdentifier {
        case UNUserNotificationCenter.standardAddActionIdentifier:
            habit.addToHabit(habit.wrappedStandardAddValue, context: moc)
            
            break
        default:
            print("OOOOF")
            
            // MARK: TODO: Open Habit wenn Notification gedrückt wird
            
            UIApplication.shared.open(URL(string: "persistent://openHabit/\(habit.id.uuidString)")!)
            
            break
        }
        
        completionHandler()
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
//        print("HEYHO")
//        let moc = PersistenceController.shared.container.viewContext
//        let request = HabitItem.fetchRequest()
//
//        var habits: [HabitItem]
//
//        do {
//            habits = try moc.fetch(request)
//        } catch {
//            habits = []
//        }
//
//        let userInfo = response.notification.request.content.userInfo
//        guard let habitID = UUID(uuidString: userInfo["HABIT_ID"] as! String) else { return }
//
//        switch response.actionIdentifier {
//        case UNUserNotificationCenter.standardAddActionIdentifier:
//            guard let habit = habits.first(where: { $0.id == habitID }) else { return }
//
//            habit.addToHabit(habit.wrappedStandardAddValue, context: moc)
//
//            break
//        default:
//            break
//        }
//    }
}
