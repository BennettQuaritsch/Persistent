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

extension View {
    func habitDeleteAlert(isPresented: Binding<Bool>, habit: HabitItem?, context: NSManagedObjectContext, dismiss: DismissAction? = nil) -> some View {
        modifier(HabitDeleteAlertViewModifier(context: context, habit: habit, isPresented: isPresented, dismiss: dismiss))
    }
}
