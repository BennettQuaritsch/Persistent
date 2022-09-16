//
//  ListViewModel.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 16.10.21.
//

import Foundation
import SwiftUI
import CoreData

enum ListFilterSelectionEnum: Equatable, Hashable, CaseIterable {
    static var allCases: [ListFilterSelectionEnum] {
        [.all, .daily, .weekly, .monthly]
    }
    
    case all
    case daily
    case weekly
    case monthly
    case tag(HabitTag)
    
    var name: String {
        switch self {
        case .all:
            return NSLocalizedString("General.ListFilterSelection.All", comment: "")
        case .daily:
            return NSLocalizedString("General.ListFilterSelection.Daily", comment: "")
        case .weekly:
            return NSLocalizedString("General.ListFilterSelection.Weekly", comment: "")
        case .monthly:
            return NSLocalizedString("General.ListFilterSelection.Monthly", comment: "")
        case .tag(let habitTag):
            return habitTag.wrappedName
        }
    }
    
    var codingID: String {
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
            return habitTag.wrappedId.uuidString
        }
    }
    
    init(from id: String, context: NSManagedObjectContext) {
        switch id {
        case "All Habits":
            self = .all
        case "Daily Habits":
            self = .daily
        case "Weekly Habits":
            self = .weekly
        case "Monthly Habits":
            self = .monthly
        default:
            guard let uuid = UUID(uuidString: id) else {
                self = .all
                return
            }
            
            let request = HabitTag.fetchRequest()
            let result = try? context.fetch(request)
            
            guard let tag = result?.first(where: { $0.wrappedId == uuid }) else {
                self = .all
                return
            }
            
            self = .tag(tag)
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
        let decoder = JSONDecoder()
        
        if let sortingOption = UserDefaults.standard.object(forKey: ListViewModel.sortingOptionUserDefaultsKey) as? Data {
            if let decodedOption = try? decoder.decode(FilterOptions.self, from: sortingOption) {
                self.sortingOption = decodedOption
            } else {
                self.sortingOption = .nameAscending
            }
        } else {
            self.sortingOption = .nameAscending
        }
        
//        if let filterOption = UserDefaults.standard.string(forKey: ListViewModel.filterOptionUserDefaultsKey) {
//            self.filterOption = ListFilterSelectionEnum(from: filterOption, context: backgroundContext)
//        } else {
//            self.filterOption = .all
//        }
    }
    
    @Published var addSheetPresented: Bool = false
    
    @Published var searchText: String = ""
    
    @Published var selection = Set<UUID>()
    
    static let sortingOptionUserDefaultsKey: String = "listViewSortingOption"
    @Published var sortingOption: FilterOptions {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(sortingOption) {
                UserDefaults.standard.set(encoded, forKey: ListViewModel.sortingOptionUserDefaultsKey)
            }
        }
    }
    
//    static let filterOptionUserDefaultsKey: String = "listViewFilterOption"
//    @Published var filterOption: ListFilterSelectionEnum {
//        didSet {
//            UserDefaults.standard.set(filterOption.codingID, forKey: ListViewModel.filterOptionUserDefaultsKey)
//        }
//    }
    
    func selectionChanged() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator()
        generator.impactOccurred()
        #endif
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
