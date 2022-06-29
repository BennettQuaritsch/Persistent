//
//  ListCellView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 12.11.21.
//

import SwiftUI

struct ListCellView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.backgroundContext) private var backgroundContext
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var appViewModel: AppViewModel
    
    #if os(iOS)
    @Environment(\.editMode) var editMode
    #endif
    
    @ObservedObject var habit: HabitItem
    @ObservedObject var viewModel: ListViewModel
    
    @State var pressed: Bool = false
    
    @State var editSheetPresented: Bool = false
    
    @ViewBuilder var listCellColor: some View {
        if userSettings.simplerListCellColor {
            Color("secondarySystemGroupedBackground")
        } else {
            ZStack {
                Color.systemGroupedBackground
                
                LinearGradient(colors: [habit.iconColor, habit.iconColor.makeColor(by: 0.06)], startPoint: .bottomTrailing, endPoint: .topLeading)
                    .opacity(0.8)
            }
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
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 10)
                
            
            HStack(alignment: .center) {
                if habit.iconName != nil {
                    ZStack {
                        Circle()
                            .fill(Color.systemBackground)
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
                    .shadow(color: colorScheme == .light ? Color.black.opacity(0.25) : .clear ,radius: 3)
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
                    
                    Text("\(habit.relevantCountTextSmall(Date().adjustedForNightOwl()))")
                        .fontWeight(.bold)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                        .frame(width: 35)
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                    
                    ProgressBar(strokeWidth: 7, color: habit.iconColor, habit: habit, date: Date().adjustedForNightOwl())
                        .frame(height: 48)
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
                        
                        let habitObject = backgroundContext.object(with: habit.objectID) as! HabitItem
                        
                        habitObject.addToHabit(habitObject.wrappedStandardAddValue, date: Date().adjustedForNightOwl(), context: backgroundContext, appViewModel: appViewModel)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation {
                                pressed = false
                            }
                        }
                        habit.objectWillChange.send()
                        viewModel.objectWillChange.send()
                    }
                    
                    selectionChangedVibration()
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
        return ListCellView(habit: HabitItem.testHabit, viewModel: ListViewModel())
            .frame(height: 80)
            .previewLayout(.sizeThatFits)
            .environmentObject(UserSettings())
    }
}
