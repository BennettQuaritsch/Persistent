//
//  ListCellView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 12.11.21.
//

import SwiftUI

struct ListCellView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var userSettings: UserSettings
    
    #if os(iOS)
    @Environment(\.editMode) var editMode
    #endif
    
    @ObservedObject var habit: HabitItem
    @ObservedObject var viewModel: ListViewModel
    
    @State var pressed: Bool = false
    
    @State var editSheetPresented: Bool = false
    
    var listCellColor: Color {
        if userSettings.simplerListCellColor {
            return Color("secondarySystemGroupedBackground")
        } else {
            return habit.iconColor.opacity(0.9)
        }
    }
    
    var textColor: Color {
        if userSettings.simplerListCellColor {
            return Color.primary
        } else {
            return Color("systemBackground")
        }
    }
    
    var body: some View {
        ZStack {
            listCellColor
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
                
            
            HStack(alignment: .center) {
                if habit.iconName != nil {
                    ZStack {
                        Circle()
                            .fill(Color("systemGroupedBackground"))
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 50, height: 50)
                        
                        Image(habit.iconName!)
                            .resizable()
                            .foregroundColor(habit.iconColor)
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 35)
                            .padding(.horizontal, 3)
                    }
                }

                Text(habit.habitName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(textColor)
                    .lineLimit(2)
                    .minimumScaleFactor(0.4)
                    .shadow(color: Color.gray.opacity(0.2) ,radius: 3)
                    .padding(.trailing, 5)

                Spacer()

                ZStack {
                    if !userSettings.simplerListCellColor {
                        Circle()
                            .fill(Color("systemBackground").opacity(0.6))
                            .frame(width: 68, height: 68)
                            .shadow(color: .black.opacity(0.125), radius: 10)
                            .padding(.vertical, 3)
                    }
                    
                    Text("\(habit.relevantCount())")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    ProgressBar(strokeWidth: 7, color: habit.iconColor, habit: habit)
                        .frame(height: 45)
                        .background(
                            Circle()
                                .stroke(Color("systemGroupedBackground"), lineWidth: 7)
                        )
                        .aspectRatio(contentMode: .fit)
                        .padding(8)
                        .drawingGroup()
                }
                .padding(.vertical, userSettings.simplerListCellColor ? 6 : 0)
                .onTapGesture {
                    withAnimation {
                        pressed = true
                        habit.addToHabit(1, context: viewContext)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation {
                                pressed = false
                            }
                        }
                        habit.objectWillChange.send()
                    }
                }
                
                .onChange(of: habit.date) { _ in
                    withAnimation {
                        viewModel.objectWillChange.send()
                    }
                }
                .scaleEffect(pressed ? 1.15 : 1)
                #if os(iOS)
    //            .disabled(editMode?.wrappedValue == .active)
                #endif
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
        }
        .sheet(isPresented: $editSheetPresented) {
            EditView(habit: habit, accentColor: .accentColor)
        }
//        .contextMenu {
//            Button {
//                editSheetPresented = true
//            } label: {
//                Label("Edit", systemImage: "pencil")
//            }
//
//            Button(role: .destructive) {
//                withAnimation {
//                    habit.deleteHabit()
//                }
//            } label: {
//                Label("Delete", systemImage: "trash")
//            }
//        }
    }
}

//extension View {
//  @inlinable
//  public func reverseMask<Mask: View>(
//    alignment: Alignment = .center,
//    @ViewBuilder _ mask: () -> Mask
//  ) -> some View {
//    self.mask {
//      Rectangle()
//        .overlay(alignment: alignment) {
//          mask()
//            .blendMode(.destinationOut)
//        }
//    }
//  }
//}

struct ListCellView_Previews: PreviewProvider {
    static var previews: some View {
        let moc = PersistenceController.preview.container.viewContext
        
        let habit = HabitItem(context: moc)
        habit.id = UUID()
        habit.habitName = "PreviewTest"
        habit.iconName = iconSections.randomElement()!.iconArray.randomElement()!
        habit.resetIntervalEnum = .daily
        habit.amountToDo = 4
        habit.iconColorIndex = Int16(iconColors.firstIndex(of: iconColors.randomElement()!)!)
        
        return ListCellView(habit: habit, viewModel: ListViewModel())
            .frame(height: 80)
            .previewLayout(.sizeThatFits)
    }
}
