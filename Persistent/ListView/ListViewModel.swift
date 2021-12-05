//
//  ListViewModel.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 16.10.21.
//

import Foundation
import SwiftUI
import CoreData

class ListViewModel: ObservableObject {
    enum FilterOptions: Codable {
        case nameAscending, nameDescending
    }
    
    @Published var addSheetPresented: Bool = false
    
    @Published var searchText: String = ""
    
    @Published var selection = Set<UUID>()
    
    @Published var filterOptions: FilterOptions = UserDefaults.standard.object(forKey: "listFilterOptions") as? FilterOptions ?? .nameAscending {
        didSet {
            UserDefaults.standard.set(filterOptions, forKey: "listFilterOptions")
        }
    }
    
    func selectionChanged() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator()
        generator.impactOccurred()
        #endif
    }
    
    func deleteHabitWithOffset(at offsets: IndexSet, items: FetchedResults<HabitItem>, context: NSManagedObjectContext) {
        for index in offsets {
            let habit = items[index]
            habit.deleteHabit()
            
            do {
                try context.save()
            } catch {
                fatalError()
            }
        }
    }
    
    func addHabitOnCirclePress(item: HabitItem, context: NSManagedObjectContext) {
        let newhabit = HabitCompletionDate(context: context)
        newhabit.date = Date()
        newhabit.item = item
        
        do {
            try context.save()
            selectionChanged()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
