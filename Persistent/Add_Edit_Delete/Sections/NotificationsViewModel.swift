//
//  NotificationsViewModel.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 25.09.21.
//

import Foundation
import SwiftUI
import CoreData
import NotificationCenter
import UserNotifications

class NotificationsViewModel: ObservableObject {
    @Published var notificationEnabled: Bool = false
    
    @Published var notificationAmount: Int = 1
    
    @Published var notificationDates: [Date] = [Date()]
    
    @Published var weekdaySelection: [Int] = [0]
    
//    init(notificationEnabled: Bool, notificationAmount: Int) {
//        self.notificationEnabled = notificationEnabled
//        self.notificationAmount = notificationAmount
//    }
    init() {
        print("Date(): \(Date())")
    }
    
    /**
    Funktion zum hinzufügen einer Notification.
     */
    func addNotification(habit: HabitItem, context: NSManagedObjectContext) {
        if notificationEnabled {
            let content = UNMutableNotificationContent()
            content.title = habit.habitName
            content.body = "Keep your habit in mind!"

            // Alle NotificationDates (also alle Notifications überhaupt) sollen hinzugefügt werden
            
            for date in notificationDates {
                // components vom jeweiligen Datum (Zeitzone angepasst)
                let components = Calendar.defaultCalendar.dateComponents([.weekday, .hour, .minute], from: date)
                
                let notificationItem = NotificationItem(context: context)
                notificationItem.wrappedID = UUID()
                notificationItem.wrappedDate = date
                notificationItem.wrappedHabit = habit
                
                do {
                    try context.save()
                    
                    // Trigger Erstellung, wird wiederholt
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

                    // UUID aus dem NotificationItem
                    let uuidString = notificationItem.wrappedID.uuidString

                    // Request Erstellen
                    let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

                    let notificationCenter = UNUserNotificationCenter.current()

                    // Authorisation, wenn granted dann die request hinzufügen
                    notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        if let error = error {
                            print(error)
                        } else if granted {
                            notificationCenter.add(request) { error in
                                if error != nil {

                                } else {
                                    print("worked")
                                }
                            }
                        }
                    }
                } catch {
                    fatalError()
                }
            }
        }
    }
    
    func editNotifications(habit: HabitItem, context: NSManagedObjectContext) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getPendingNotificationRequests { requests in
            var identifiers = [String]()
            
            let notificationArray = habit.notificationArray
            
            let notificationIDStringArray: [String] = notificationArray.map { $0.wrappedID.uuidString }
            
            for request in requests {
                if notificationIDStringArray.contains(request.identifier) {
                    identifiers.append(request.identifier)
                }
            }
            
            notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
            
            let notificationIDStrings = habit.notificationArray.map { $0.wrappedID.uuidString }
            
            // Vorhandene Notification-Items löschen
            for notificationIDString in notificationIDStrings {
                if identifiers.contains(notificationIDString) {
                    if let notification = habit.notificationArray.first(where: { $0.wrappedID.uuidString == notificationIDString }) {
                        print("deleting notification")
                        
                        context.delete(notification)
                        
                        context.perform {
                            do {
                                try context.save()
                            } catch {
                                fatalError(error.localizedDescription)
                            }
                        }
                    }
                }
            }
        }
            
        addNotification(habit: habit, context: context)
    }
    
    func loadNotifications(habit: HabitItem, context: NSManagedObjectContext) {
        var dates: [Date] = []
        var count = 0
        var enabled: Bool = false
        
        let notificationDatesArray = habit.notificationArray.map { $0.wrappedDate }
        
        for notificationDate in notificationDatesArray {
            count += 1
            dates.append(notificationDate)
        }
        
        count = max(1, count)
        
        if dates.isEmpty {
            dates = [Date()]
            enabled = false
        } else {
            enabled = true
        }
        
        self.notificationDates = dates
        self.notificationEnabled = enabled
        self.notificationAmount = count
    }
}
