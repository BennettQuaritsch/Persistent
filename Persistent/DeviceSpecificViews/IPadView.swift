//
//  IPadView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 09.06.21.
//

import SwiftUI
import CoreData

struct IPadView: View {
//    var dayPredicate: NSPredicate {
//        let startDate = Calendar.current.startOfDay(for: Date())
//        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
//
//        return NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate! as NSDate)
//    }
//
//    var WeekPredicate: NSPredicate {
//        var startDate = Calendar.current.startOfDay(for: Date())
//        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
//        if let date = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: startDate) {
//            startDate = date
//        }
//
//        return NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate! as NSDate)
//    }
//
//    var MonthPredicate: NSPredicate {
//        var startDate = Calendar.current.startOfDay(for: Date())
//        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)
//        if let date = Calendar.current.date(byAdding: .month, value: -1, to: startDate) {
//            startDate = date
//        }
//
//        return NSPredicate(format: "date >= %@ AND date < %@", startDate as NSDate, endDate! as NSDate)
//    }
    
    var dayPredicate: [NSPredicate]? {
        return [NSPredicate(format: "resetInterval == 'daily'")]
    }
    
    var weekPredicate: [NSPredicate]? {
        return [NSPredicate(format: "resetInterval == 'weekly'")]
    }
    
    var monthPredicate: [NSPredicate]? {
        return [NSPredicate(format: "resetInterval == 'monthly'")]
    }
    
    init() {
        UIApplication.shared.setFirstSplitViewPreferredDisplayMode(.twoBesideSecondary)
    }
    
    @State var selection: Int? = 1
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ListView()) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(.purple)
                            .font(.title2)
                        
                        Text("All Habits")
                    }
                    
                }
                
                DisclosureGroup(content: {
                    NavigationLink(destination: ListView(predicate: dayPredicate)) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.purple)
                                .font(.title2)
                            
                            Text("Daily Habits")
                        }
                        
                    }
                    
                    NavigationLink(destination: ListView(predicate: weekPredicate)) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.purple)
                                .font(.title2)
                            
                            Text("Weekly Habits")
                        }
                        
                    }
                    
                    NavigationLink(destination: ListView(predicate: monthPredicate)) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.purple)
                                .font(.title2)
                            
                            Text("Monthly Habits")
                        }
                       
                    }
                }) {
                    Text("Specifics")
                        .bold()
                }
            }
            .accentColor(.blue)
            .navigationBarTitle("Persistent")
            
            Text("No Sidebar Selection") // You won't see this in practice (default selection)
            Text("No Habit Chosen") // You will see this
        }
    }
}



// MARK: - Consistency with iPad
#if canImport(UIKit)
private extension UIApplication {
    func setFirstSplitViewPreferredDisplayMode(_ preferredDisplayMode: UISplitViewController.DisplayMode) {
        var splitViewController: UISplitViewController? {
            UIApplication.shared.firstSplitViewController
        }
        
        // Sometimes split view is not available instantly
        if let splitViewController = splitViewController {
            splitViewController.preferredDisplayMode = preferredDisplayMode
        } else {
            DispatchQueue.main.async {
                splitViewController?.preferredDisplayMode = preferredDisplayMode
            }
        }
    }
    
    private var firstSplitViewController: UISplitViewController? {
        windows.first { $0.isKeyWindow }?
            .rootViewController?.firstSplitViewController
    }
}

private extension UIViewController {
    var firstSplitViewController: UISplitViewController? {
        self as? UISplitViewController
            ?? children.lazy.compactMap { $0.firstSplitViewController }.first
    }
}
#endif


struct IPadView_Previews: PreviewProvider {
    static var previews: some View {
        IPadView()
            .previewDevice("iPad Pro (11-inch) (3rd generation)")
    }
}
