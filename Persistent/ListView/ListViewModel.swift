//
//  ListViewModel.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 16.10.21.
//

import Foundation
import SwiftUI
import CoreData

enum ListFilterSelectionEnum: Equatable {
    case all
    case daily
    case weekly
    case monthly
    case tag(HabitTag)
    
    var name: String {
        switch self {
        case .all:
            return "All Habits"
        case .daily:
            return "Daily Habits"
        case .weekly:
            return "Weekly Habits"
        case .monthly:
            return "Monthly Habits"
        case .tag(let habitTag):
            return habitTag.wrappedName
        }
    }
}

class ListViewModel: ObservableObject {
    enum FilterOptions: Codable {
        case nameAscending
        case nameDescending
        case percentageDoneAscending
        case percentageDoneDescending
    }
    
    init() {
        if let filterOptions = UserDefaults.standard.object(forKey: "listFilterOptions") as? Data {
            let decoder = JSONDecoder()
            if let decodedOption = try? decoder.decode(FilterOptions.self, from: filterOptions) {
                self.filterOptions = decodedOption
            } else {
                self.filterOptions = .nameAscending
            }
        } else {
            self.filterOptions = .nameAscending
        }
    }
    
    @Published var addSheetPresented: Bool = false
    
    @Published var searchText: String = ""
    
    @Published var selection = Set<UUID>()
    
    @Published var filterOptions: FilterOptions {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(filterOptions) {
                UserDefaults.standard.set(encoded, forKey: "listFilterOptions")
            }
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
