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
            ZStack {
                Color(UIColor.systemGray6)
                    .edgesIgnoringSafeArea(.all)
                
                ListView(predicate: chosenPredicate)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            habitListMenu
                        }
                    }
                    .sheet(isPresented: $addSheetPresented, content: { AddHabitView(accentColor: userSettings.accentColor)
                        .environment(\.managedObjectContext, self.viewContext)
                    })
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(Color.accentColor)
                            
                            Image(systemName: "plus")
                                .foregroundColor(.primary)
                        }
                        .frame(width: 50, height: 50)
                        .onTapGesture {
                            addSheetPresented = true
                        }
                        .shadow(radius: 5)
                        .padding()
                    }
                }
            }
        }
    }
    
    var addButton: some View {
        Image(systemName: "plus")
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .font(.title2.weight(.semibold))
            .onTapGesture {
                addSheetPresented = true
            }
            .foregroundColor(.accentColor)
            .frame(minWidth: 22, minHeight: 22)
            .contentShape(Rectangle())
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
            Image(systemName: "ellipsis.circle")
                .font(.title2)
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
