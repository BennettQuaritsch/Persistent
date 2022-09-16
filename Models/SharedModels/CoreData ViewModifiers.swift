//
//  ViewModifiers.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 20.04.22.
//

import Foundation
import SwiftUI
import CoreData.NSManagedObjectContext

struct HabitDeleteAlertViewModifier: ViewModifier {
    let context: NSManagedObjectContext
    
    let habit: HabitItem?
    @Binding var isPresented: Bool
    
    let dismiss: DismissAction?
    
    func body(content: Content) -> some View {
        content
            .alert("Do you really want to delete this habit?", isPresented: $isPresented) {
                Button("Delete", role: .destructive) {
                    if let habit = habit {
                        let id = habit.objectID
                        
                        if let dismiss = dismiss {
                            dismiss()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            let habitItem = context.object(with: id) as! HabitItem
                            context.delete(habitItem)
                            
                            if context.hasChanges {
                                do {
                                    try context.save()
                                    PersistentShortcuts.updateAppShortcutParameters()
                                } catch {
                                    print("Error")
                                    
                                    let nsError = error as NSError
                                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                }
                            }
                        }
                    }
                }
            } message: {
                
            }
    }
}

extension HabitItem {
    func archiveHabit(context: NSManagedObjectContext) {
        #if os(iOS)
        let notificationCenter = UNUserNotificationCenter.current()
        
        let habitNotifications = notificationArray
        
        var notificationIDs: [String] = []
        
        for notification in habitNotifications {
            for weekday in notification.weekdayEnumSet {
                let id = notification.wrappedID.uuidString + " - \(weekday.id)"
                
                notificationIDs.append(id)
            }
            
            context.delete(notification)
        }
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: notificationIDs)
        #endif
        
        self.habitArchived = true
        
        do {
            try context.save()
            PersistentShortcuts.updateAppShortcutParameters()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func unarchiveHabit(context: NSManagedObjectContext) {
        self.habitArchived = false
        
//        addNotifications(habit: self, moc: context)
        
        do {
            try context.save()
            PersistentShortcuts.updateAppShortcutParameters()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func deleteHabitPermanently(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        context.delete(self)
        
        do {
            try context.save()
            PersistentShortcuts.updateAppShortcutParameters()
        } catch {
            print("Error")
            
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

fileprivate func addNotifications(habit: HabitItem, moc: NSManagedObjectContext) {
    // Lokalisierter Kalendar
    let calendar: Calendar = Calendar.defaultCalendar
//        var calendar = Calendar.current
//        let prefLanguage = Locale.preferredLanguages[0]
//        calendar.locale = .init(identifier: prefLanguage)
    
    // Jede Notification loopen
    for notificationDate in habit.notificationArray {
        // MEssage festlegen, ist für jeden Tag gleich
        let content = UNMutableNotificationContent()
        content.title = habit.habitName
        content.body = notificationDate.wrappedMessage
        
        content.categoryIdentifier = UNUserNotificationCenter.habitNotificationCategoryIdentifier
        content.userInfo = ["HABIT_ID": habit.id.uuidString]
        
        var components = calendar.dateComponents([.hour, .minute], from: notificationDate.wrappedDate)
        
        
        
        let notificationCenter = UNUserNotificationCenter.current()
        // Für jeden Weekday loopen
        for notificationWeekday in notificationDate.wrappedIntSetForCalendar {
            // Eventuell weekday ausgleichen?
            components.weekday = ((notificationWeekday - 1) + (calendar.firstWeekday - 1)) % 7 + 1
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            
//                print("trigger:", components.weekday)
//                print("time: \(components.hour!) \(components.minute)")

            // UUID aus dem NotificationItem
            //let uuidString = notificationItem.wrappedID.uuidString
            let uuidString = notificationDate.wrappedID.uuidString + " - \(notificationWeekday)"
            
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
                }
            }
        }
    }
}

extension View {
    func habitDeleteAlert(isPresented: Binding<Bool>, habit: HabitItem?, context: NSManagedObjectContext, dismiss: DismissAction? = nil) -> some View {
        modifier(HabitDeleteAlertViewModifier(context: context, habit: habit, isPresented: isPresented, dismiss: dismiss))
    }
}
