//
//  NewNotificationsViewModel.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 02.12.21.
//

import Foundation
import NotificationCenter
import CoreData.NSManagedObjectContext


struct NotificationDate: Identifiable {
    let id = UUID()
    
    var message: String
    var date: Date
    var weekdays: Set<Int>
}

func weekdayNameFrom(weekdayNumber: Int) -> String {
//    var calendar = Calendar.current
//    let prefLanguage = Locale.preferredLanguages[0]
//    calendar.locale = .init(identifier: prefLanguage)
    let calendar: Calendar = Calendar.defaultCalendar
    let dayIndex = ((weekdayNumber - 1) + (calendar.firstWeekday - 1)) % 7
    return calendar.shortWeekdaySymbols[dayIndex]
}

class NewNotificationsViewModel: ObservableObject {
    @Published var notifcationArray: [NotificationDate] = []
    
    @Published var alertPresented: Bool = false
    
    func addNotifications(habit: HabitItem, moc: NSManagedObjectContext) {
        // Lokalisierter Kalendar
        let calendar: Calendar = Calendar.defaultCalendar
//        var calendar = Calendar.current
//        let prefLanguage = Locale.preferredLanguages[0]
//        calendar.locale = .init(identifier: prefLanguage)
        
        // Jede Notification loopen
        for notificationDate in notifcationArray {
            // MEssage festlegen, ist für jeden Tag gleich
            let content = UNMutableNotificationContent()
            content.title = habit.habitName
            content.body = notificationDate.message
            
            let newNotificationItem = NotificationItem(context: moc)
            newNotificationItem.id = UUID()
            newNotificationItem.date = notificationDate.date
            newNotificationItem.habit = habit
            if notificationDate.message.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                newNotificationItem.wrappedMessage = notificationDate.message
            } else {
                newNotificationItem.wrappedMessage = "Remember your habit!"
            }
            newNotificationItem.wrappedIntSet = notificationDate.weekdays
            
            var components = calendar.dateComponents([.hour, .minute], from: notificationDate.date)
            
            
            
            let notificationCenter = UNUserNotificationCenter.current()
            // Für jeden Weekday loopen
            for notificationWeekday in notificationDate.weekdays {
                // Eventuell weekday ausgleichen?
                components.weekday = ((notificationWeekday - 1) + (calendar.firstWeekday - 1)) % 7 + 1
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                
                print("trigger: \(trigger)")

                // UUID aus dem NotificationItem
                //let uuidString = notificationItem.wrappedID.uuidString
                let uuidString = newNotificationItem.wrappedID.uuidString + " - \(notificationWeekday)"
                
                // Request Erstellen
                let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                
                Task {
                    do {
                        let authorization = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
                        
                        //let settings = await notificationCenter.notificationSettings()
                        
                        if authorization {
                            print("Authorization granted")
                            
                            try await notificationCenter.add(request)
                        }
                    } catch {
                        print("Fehler")
                        
                        alertPresented = true
                    }
                }
            }
        }
    }
    
    func editNotifications(habit: HabitItem, moc: NSManagedObjectContext) {
        let notificationCenter = UNUserNotificationCenter.current()
        
        let habitNotifications = habit.notificationArray
        
        var notificationIDs: [String] = []
        
        for notification in habitNotifications {
            for weekday in notification.weekdayEnumSet {
                let id = notification.wrappedID.uuidString + " - \(weekday.id)"
                
                notificationIDs.append(id)
            }
            
            moc.delete(notification)
        }
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: notificationIDs)
        
        addNotifications(habit: habit, moc: moc)
    }
    
    func loadNotifications(habit: HabitItem) {
        let habitNotifications = habit.notificationArray
        
        var tempNotificationArray: [NotificationDate] = []
        
        for notification in habitNotifications {
            print(notification.wrappedDate)
            tempNotificationArray.append(NotificationDate(message: notification.wrappedMessage, date: notification.wrappedDate, weekdays: notification.wrappedIntSet))
        }
        
        self.notifcationArray = tempNotificationArray
    }
}
