//
//  TestAddHabitView.swift
//  PersistentMac
//
//  Created by Bennett Quaritsch on 29.10.21.
//

import SwiftUI

struct TestAddHabitView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    let accentColor: Color
    
    @State var name = ""
    @State var description = ""
    @State var amountToDo: Int16 = 3
    @State var intervalChoice = "Day"
    
    @State var tagSelection = Set<UUID>()
    
    let uuid = UUID()
    
    @State private var iconChoice: String = "person"
    @State private var colorSelection: Int = 0
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Name & Description")) {
                        TextField("Name", text: $name)

                        TextField("Description", text: $description)
                    }

                    Section(header: Text("How often?")) {
                        ResertIntervalPickerView(intervalChoice: $intervalChoice, timesPerDay: $amountToDo)
                    }

                    Section(header: Text("Symbol & Color")) {
                        SymbolColorView(iconChoice: $iconChoice, colorSelection: $colorSelection)
                    }

//                    Section(header: Text("Notifications")) {
//                        NotificationsView(viewModel: notificationsViewModel)
//                    }

                    addHabitButton
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("Close")
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        //addHabit()
                    } label: {
                        Label("Save", systemImage: "plus")
                    }
                }
            }
        }
        .accentColor(accentColor)

    }
    
    var addHabitButton: some View {
        Button("Add your Habit") {
            addHabit()
        }
    }
    
    func addHabit() {
        let newhabit = HabitItem(context: viewContext)
        newhabit.id = uuid
        newhabit.habitName = name
        if description.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
            newhabit.habitDescription = description
        }
        newhabit.amountToDo = self.amountToDo
        
        let habitInterval: ResetIntervals
        
        switch intervalChoice {
        case "Day":
            habitInterval = .daily
        case "Week":
            habitInterval = .weekly
        case "Month":
            habitInterval = .monthly
        default:
            habitInterval = .daily
        }
        
        newhabit.resetIntervalEnum = habitInterval
        
        newhabit.iconName = iconChoice
        
        newhabit.iconColorIndex = Int16(colorSelection)
        
        let tags = try? viewContext.fetch(NSFetchRequest<HabitTag>(entityName: "HabitTag"))
        if let tags = tags {
            let chosenTags = tags.filter { tagSelection.contains($0.wrappedId) }
            for tag in chosenTags {
                print(tag)
            }
            
            newhabit.tags = NSSet(array: chosenTags)
            
        }
        
        
        viewContext.perform {
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        
        dismiss()
    }
}

struct TestAddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        TestAddHabitView(accentColor: .red)
    }
}
