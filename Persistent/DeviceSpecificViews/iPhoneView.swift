//
//  iPhoneView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 13.06.21.
//

import SwiftUI

struct iPhoneView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var addSheetPresented = false
    @State private var chosenPredicate: [NSPredicate]? = nil
    @EnvironmentObject private var userSettings: UserSettings
    
    @FetchRequest(entity: HabitTag.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HabitTag.name, ascending: true)]) var tags: FetchedResults<HabitTag>
    
    @EnvironmentObject var settings: UserSettings
        
        var dayPredicate: NSPredicate {
            return NSPredicate(format: "resetInterval == 'daily'")
        }
        
        var weekPredicate: NSPredicate {
            return NSPredicate(format: "resetInterval == 'weekly'")
        }
        
        var monthPredicate: NSPredicate {
            return NSPredicate(format: "resetInterval == 'monthly'")
        }
    
    func tagPredicate(_ tag: HabitTag) -> NSPredicate {
        return NSPredicate(format: "%@ IN tags", tag)
    }
    
    var body: some View {
        NavigationView {
            ListView(predicate: chosenPredicate)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        habitListMenu
                    }
                }
        }
    }
    

    func predicateButton(predicate: NSPredicate?, text: String, imageName: String? = nil) -> some View {
        Button(action: {
            withAnimation(.easeInOut) {
                if let predicate = predicate {
                    chosenPredicate = [predicate]
                } else {
                    chosenPredicate = nil
                }
            }
        }) {
            if let imageName = imageName {
                Label(text, systemImage: imageName)
            } else {
                Text(text)
            }
        }
    }
    
    var habitListMenu: some View {
        Menu() {
//            Menu {
//                Button("Ascending") {
//                    viewModel.filterOptions = .nameAscending
//                }
//                
//                Button("Descending") {
//                    viewModel.filterOptions = .nameDescending
//                }
//            } label: {
//                Label("Sorting", systemImage: "line.3.horizontal")
//            }
            
            predicateButton(predicate: nil, text: "All Habits", imageName: "checkmark.circle")
            
            Menu {
                predicateButton(predicate: dayPredicate, text: "Daily Habits")
                
                predicateButton(predicate: weekPredicate, text: "Weekly Habits")
                
                predicateButton(predicate: monthPredicate, text: "Monthly Habits")
            } label: {
                Label("Intervals", systemImage: "timer")
            }
            
            Menu {
                ForEach(tags) { tag in
                    predicateButton(predicate: tagPredicate(tag), text: tag.wrappedName)
                }
            } label: {
                Label("Tags", systemImage: "bookmark")
            }
            
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                //.font(.title2)
                .contentShape(Rectangle())
        }
    }
}



struct iPhoneView_Previews: PreviewProvider {
    static var previews: some View {
        iPhoneView()
            //.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
