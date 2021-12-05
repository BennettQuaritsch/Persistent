//
//  ListCellView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 12.11.21.
//

import SwiftUI

struct ListCellView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    #if os(iOS)
    @Environment(\.editMode) var editMode
    #endif
    
    @ObservedObject var habit: HabitItem
    @ObservedObject var viewModel: ListViewModel
    
    @State var pressed: Bool = false
    
    @State var editSheetPresented: Bool = false
    
    var body: some View {
        HStack(alignment: .center) {
            if habit.iconName != nil {
                Image(habit.iconName!)
                    .resizable()
                    .foregroundColor(habit.iconColor)
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    //.padding(.trailing, 5)
            }

            Text(habit.habitName)
                .font(.title)
                .fontWeight(.semibold)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .padding(.trailing, 5)

            Spacer()

            ZStack {
                Text("\(habit.relevantCount())/\(habit.amountToDo)")
                    .fontWeight(.bold)
                ProgressBar(strokeWidth: 7, progress: CGFloat(habit.relevantCount()) / CGFloat(habit.amountToDo), color: habit.iconColor)
                    .frame(height: 50)
                    .aspectRatio(contentMode: .fit)
            }
            .padding(.trailing)
            .padding(.vertical, 3)
            .onTapGesture {
                withAnimation {
                    pressed = true
                    habit.addToHabit(1, context: viewContext)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        withAnimation {
                            pressed = false
                        }
                    }
                }
            }
            .scaleEffect(pressed ? 1.15 : 1)
//            .onLongPressGesture(minimumDuration: 0.01) {
//                withAnimation {
//                    viewModel.addHabitOnCirclePress(item: habit, context: viewContext)
//                }
//            } onPressingChanged: { pressed in
//                withAnimation {
//                    self.pressed = pressed
//                }
//            }
            #if os(iOS)
            .disabled(editMode?.wrappedValue == .active)
            #endif
        }
        .sheet(isPresented: $editSheetPresented) {
            EditView(habit: habit, accentColor: .accentColor)
        }
        .contextMenu {
            Button {
                editSheetPresented = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            
            Button(role: .destructive) {
                withAnimation {
                    habit.deleteHabit()
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct ListCellView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = PersistenceController().container.viewContext
        
        let habit = HabitItem(context: moc)
        habit.id = UUID()
        habit.habitName = "PreviewTest"
        habit.iconName = iconChoices.randomElement()!
        habit.resetIntervalEnum = .daily
        habit.amountToDo = 4
        habit.iconColorIndex = Int16(iconColors.firstIndex(of: iconColors.randomElement()!)!)
        
        for _ in 1...Int.random(in: 1...6) {
            let date = HabitCompletionDate(context: moc)
            date.date = Date()
            date.item = habit
        }
        
        return ListCellView(habit: habit, viewModel: ListViewModel())
    }
}
