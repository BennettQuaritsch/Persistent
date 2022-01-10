//
//  AppViewModel.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 28.12.21.
//

import Foundation
import CoreData
import UserNotifications

class AppViewModel: ObservableObject {
    @Published var habitToDelete: HabitItem? {
        didSet {
            if habitToDelete != nil {
                deleteActionSheet = true
            } else {
                deleteActionSheet = false
            }
        }
    }
    
    @Published var deleteActionSheet = false
    
    static let versionBuildUserDefaultsKey: String = "versionBuildKey"
    @Published var showLaunchscreenSheet: Bool = false
    
    static let firstAppLaunchUserDefaultsKey: String = "firstAppLaunchedKey"
    @Published var showWelcomeSheet: Bool = false
    
    func checkIfFirstAppLaunch() {
        if !UserDefaults.standard.bool(forKey: AppViewModel.firstAppLaunchUserDefaultsKey) {
            self.showWelcomeSheet = true
            
            UserDefaults.standard.set(true, forKey: AppViewModel.firstAppLaunchUserDefaultsKey)
        }
    }
    
    func checkIfLaunchscreenSeen() {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        
        let identifierString = "\(version) - \(build)"
        
        if identifierString != UserDefaults.standard.string(forKey: AppViewModel.versionBuildUserDefaultsKey) {
            self.showLaunchscreenSheet = true
            
            UserDefaults.standard.set(identifierString, forKey: AppViewModel.versionBuildUserDefaultsKey)
        }
    }
}

func checkForNotificationsInBackground(context: NSManagedObjectContext) async {
    var notificationItems: [NotificationItem] = []
    
    do {
        let fetchRequest: NSFetchRequest<NotificationItem> = NotificationItem.fetchRequest()
        
        notificationItems = try context.fetch(fetchRequest)
    } catch {
        return
    }
    
    
    if !notificationItems.isEmpty {
        let calendar: Calendar = Calendar.defaultCalendar
        var notificationRequests: [UNNotificationRequest] = []
        
        for notificationItem in notificationItems {
            var components = calendar.dateComponents([.hour, .minute], from: notificationItem.date ?? Date())
            
            let content = UNMutableNotificationContent()
            content.title = notificationItem.wrappedHabit.habitName
            content.body = notificationItem.wrappedMessage
            
            for notificationWeekdayInt in notificationItem.wrappedIntSet {
                components.weekday = ((notificationWeekdayInt - 1) + (calendar.firstWeekday - 1)) % 7 + 1
                
                let id = notificationItem.wrappedID.uuidString + " - \(notificationWeekdayInt)"
                
                notificationRequests.append(UNNotificationRequest(identifier: id, content: content, trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)))
            }
            
            
        }
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        do {
            notificationCenter.removeAllPendingNotificationRequests()
            
            let authorization = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            
            //let settings = await notificationCenter.notificationSettings()
            
            if authorization {
                print("Authorization granted")
                
                for request in notificationRequests {
                    try await notificationCenter.add(request)
                }
            }
        } catch {
            print("Fehler beim Setzen der Notifications")
        }
    }
}
