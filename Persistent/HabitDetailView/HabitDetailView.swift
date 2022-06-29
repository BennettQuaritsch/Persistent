//
//  NewHabitDetailView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 14.05.21.
//

import SwiftUI
import CoreData



struct HabitDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.backgroundContext) private var backgroundContext
    
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var appViewModel: AppViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.parentSizeClass) var parentSizeClass
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.purchaseInfo) var purchaseInfo
    @Environment(\.scenePhase) var scenePhase
    
    init(habit: HabitItem, listViewModel: ListViewModel) {
        self.habit = habit
        
        switch habit.resetIntervalEnum {
        case .daily:
            habitIntervalString = "day"
        case .weekly:
            habitIntervalString = "week"
        case .monthly:
            habitIntervalString = "month"
        }
        
        self._viewModel = StateObject(wrappedValue: HabitDetailViewModel(habit: habit, listViewModel: listViewModel))
        self.listViewModel = listViewModel
        
        self._habitTimer = StateObject(wrappedValue: HabitTimer(habit: habit))
        
        print("habit:")
        dump(habit)
    }
    
    @StateObject private var viewModel: HabitDetailViewModel
    
    @ObservedObject private var listViewModel: ListViewModel
    
    @FocusState private var multipleAddViewTextFieldFocused: Bool
    
    var habitIntervalString: String
    
    @ObservedObject var habit: HabitItem
    
    @StateObject var habitTimer: HabitTimer
    
    // Delete habit action
    
    @State private var deleteHabitAlertActive: Bool = false
    
    @ViewBuilder var habitCircle: some View {
        ZStack {
            ProgressBar(strokeWidth: horizontalSizeClass == .regular ? 35 : 30, color: habit.iconColor, habit: habit, date: viewModel.shownDate)
                .frame(maxWidth: 500)
                .background(
                    Circle()
                        .stroke(habit.iconColor.opacity(0.2), lineWidth: horizontalSizeClass == .regular ? 35 : 30)
                )
                .padding(25)
                .drawingGroup()
                
            
            HStack {
                Button {
                    viewModel.removeFromHabit(context: viewContext)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .buttonStyle(.plain)
                    #if os(macOS)
                        .frame(minWidth: 40, maxWidth: 50)
                    #else
                        .frame(height: 40)
                    #endif
                }
                .buttonStyle(.plain)
                .keyboardShortcut("-", modifiers: [.command])
                .hoverEffect(.lift)
                
                Spacer()
                
                VStack(spacing: 20) {
//                    if habit.valueTypeEnum == .timeHours || habit.valueTypeEnum == .timeMinutes {
//                        Spacer()
//                        #if os(macOS)
//                            .frame(minWidth: 40, maxWidth: 50)
//                        #else
//                            .frame(width: 40, height: 40)
//                        #endif
//                    }
                    
                    Text(habit.relevantCountText(viewModel.shownDate))
                        .font(.system(size: horizontalSizeClass == .regular ? 45 : 35, weight: .black, design: .rounded))
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 5)
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                        .frame(minWidth: 30)
                    
//                    if habit.valueTypeEnum == .timeHours || habit.valueTypeEnum == .timeMinutes {
//                        Button {
//                            if habitTimer.timerRunning {
//                                habitTimer.stop()
//                                viewModel.objectWillChange.send()
//                                habit.objectWillChange.send()
//                            } else {
//                                habitTimer.start()
//                            }
//
//                        } label: {
//                            Image(systemName: habitTimer.timerRunning ? "stop.circle.fill" : "play.circle.fill")
//                                .renderingMode(.template)
//                                .resizable()
//                                .scaledToFit()
//                                .foregroundStyle(.white, habitTimer.timerRunning ? .red : .green)
//                            #if os(macOS)
//                                .frame(minWidth: 40, maxWidth: 50)
//                            #else
//                                .frame(height: 40)
//                            #endif
//                        }
//                        .buttonStyle(.plain)
//                        .keyboardShortcut("+", modifiers: [.command])
//                        .hoverEffect(.lift)
//                        .onAppear {
//                            habitTimer.context = viewContext
//                            habitTimer.shouldStart()
//                        }
//                        .onDisappear {
////                            habitTimer.saveDate()
////                            habitTimer.pause()
//                        }
//                        .onChange(of: scenePhase) { scene in
//                            if scene == .background {
//                                habitTimer.saveDate()
//                                habitTimer.pause()
//                            } else if scene == .active {
//                                habitTimer.checkForDate()
//                            }
//                        }
//                    }
                    
                }
                .onTapGesture {
                    if !quickAddViewShown {
                        withAnimation(springAnimation) {
                            viewModel.multipleAddShown = true
                            
                            multipleAddViewTextFieldFocused = true
                        }
                    }
                }
                
                Spacer()
                
                Button {
                    print("button: \(habit.relevantCount().formatted())")
                    viewModel.addToHabit(context: viewContext)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                    #if os(macOS)
                        .frame(minWidth: 40, maxWidth: 50)
                    #else
                        .frame(height: 40)
                    #endif
                }
                .buttonStyle(.plain)
                .keyboardShortcut("+", modifiers: [.command])
                .hoverEffect(.lift)
            }
            .padding(.horizontal, parentSizeClass == .compact ? 60 : 70)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
    
    @State private var quickAddViewShown: Bool = false
    
    var springAnimation: Animation = .spring(response: 0.25, dampingFraction: 0.6, blendDuration: 1)
    var scaleTransition: AnyTransition {
        return .asymmetric(
            insertion: .scale(scale: 0.4)
                .animation(springAnimation),
            removal: .scale(scale: 0.4)
                .animation(.easeIn(duration: 0.10)))
                .combined(with: .opacity)
    }
    
    var QuickAddViewButton: some View {
        Button {
            if !viewModel.multipleAddShown {
                withAnimation(.easeOut(duration: 0.15)) {
                    quickAddViewShown.toggle()
                }
            }
        } label: {
            HStack {
                Image(systemName: "plus")
                
                Text("Quick Add")
            }
            .padding()
            .foregroundColor(.systemBackground)
            .font(.title3.weight(.semibold))
        }
        .buttonStyle(.plain)
        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .hoverEffect(.lift)
        .padding(.horizontal)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                VStack(spacing: 0) {
                    HStack {
                        if let icon = habit.iconName {
                            Image(icon)
                                .resizable()
                                .foregroundColor(habit.iconColor)
                                .scaledToFit()
                                .frame(maxWidth: 45)
                        }
                        
                        Text(habit.habitName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                    .padding(.top)
                    .layoutPriority(10)
                    
                    Text("Goal of \(habit.amountToDoString()) per \(habit.resetIntervalEnum.noun)")
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                    
                    Spacer()
                        .frame(minHeight: parentSizeClass == .regular ? 0 : 10, maxHeight: 20)
                        .layoutPriority(0)
                    
                    habitCircle
                        .frame(minWidth: 150, maxWidth: .infinity)
                        .layoutPriority(10)
                    
                    Spacer()
                        .frame(minHeight: parentSizeClass == .regular ? 10 : 0)
                        .layoutPriority(0)
                    
                    QuickAddViewButton
                    
                    Spacer()
                        .frame(minHeight: parentSizeClass == .regular ? 10 : 0, maxHeight: 20)
                        .layoutPriority(-1)
                    
                    HStack {
                        Circle()
                            .scaledToFit()
                            .foregroundColor(.accentColor)
                            .overlay(
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 25))
                                    .foregroundColor(.init("systemBackground"))
                                    .onTapGesture {
                                        viewModel.graphSheet = true
                                    }
                            )
                            .frame(height: 50)
                            .hoverEffect(.lift)
                            .padding()
                        
                        Circle()
                            .scaledToFit()
                            .foregroundColor(.accentColor)
                            .overlay(
                                Image(systemName: "calendar")
                                    .font(.system(size: 25))
                                    .foregroundColor(.init("systemBackground"))
                                    .onTapGesture {
                                        viewModel.calendarSheet = true
                                    }
                            )
                            .frame(height: 50)
                            .hoverEffect(.lift)
                            .padding()
                    }
                    
                    if parentSizeClass == .regular {
                        Spacer()
                            .frame(minHeight: 20, maxHeight: 30)
                            .layoutPriority(1)
                    }
                    
                    //NavigationLink("Graph", destination: HabitCompletionGraph(habit: habit))
                
                }
                #if os(iOS)
                .navigationBarTitle("", displayMode: .inline)
                #endif
                .toolbar(content: {
                    ToolbarItem(placement: .primaryAction) {
                        Menu {
                            Section {
                                Button(action: {
                                    viewModel.multipleAddShown = true
                                    
                                    multipleAddViewTextFieldFocused = true
                                }) {
                                    Label("Add or Remove", systemImage: "plus.forwardslash.minus")
                                }
                            }
                            
                            Section {
                                Button(action: {
                                    viewModel.editSheet = true
                                }) {
                                    Label("Edit", systemImage: "pencil")
                                }
                            }
                            
                            Section {
                                Button {
                                    withAnimation {
                                        if habit.habitArchived {
                                            habit.unarchiveHabit()
                                        } else {
                                            habit.deleteHabit()
                                        }
                                    }
                                } label: {
                                    if habit.habitArchived {
                                        Label("Unrchive", systemImage: "archivebox")
                                    } else {
                                        Label("Archive", systemImage: "archivebox")
                                    }
                                }
                                
                                Button(role: .destructive) {
                                    withAnimation(.easeInOut) {
                                        deleteHabitAlertActive = true
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
    //                            .resizable()
    //                            .aspectRatio(1, contentMode: .fit)
                                //.font(.title2.weight(.semibold))
                        }
                        .frame(height: 25)
                    }
                })
                .sheet(isPresented: $viewModel.editSheet) {
                    EditView(habit: habit, accentColor: userSettings.accentColor)
                        .environment(\.managedObjectContext, self.viewContext)
                }
                .sheet(isPresented: $viewModel.calendarSheet) {
                    CalendarPageViewController(
                        toggle: $viewModel.calendarSheet,
                        habitDate: $viewModel.shownDate,
                        date: Date(),
                        habit: habit
                    )
                        .accentColor(userSettings.accentColor)
                        .environment(\.horizontalSizeClass, horizontalSizeClass)
                        .environment(\.colorScheme, colorScheme)
                        .environment(\.parentSizeClass, parentSizeClass)
                }
                .sheet(isPresented: $viewModel.graphSheet) {
                    HabitSpecificGraphsView(habit: habit)
                        .accentColor(userSettings.accentColor)
                        .environment(\.purchaseInfo, purchaseInfo)
                }
                .alert(isPresented: $viewModel.deleteActionSheet) {
                    Alert(title: Text("Do you really want to delete this habit?"), primaryButton: .destructive(Text("Delete")) {
                        habit.deleteHabitPermanently()
                    }, secondaryButton: .cancel())
                }
                .ignoresSafeArea(.keyboard)
                .zIndex(1)
                .disabled(viewModel.multipleAddShown || quickAddViewShown)
                .blur(radius: viewModel.multipleAddShown || quickAddViewShown ? 10 : 0)
                .contentShape(Rectangle())
                .disabled(viewModel.multipleAddShown)
                .onTapGesture {
                    if viewModel.multipleAddShown {
                        withAnimation(.easeOut(duration: 0.15)) {
                            viewModel.multipleAddShown = false
                        }
                    }
                    if quickAddViewShown {
                        withAnimation(.easeOut(duration: 0.15)) {
                            quickAddViewShown = false
                        }
                    }
                }
                
                if viewModel.multipleAddShown {
                    AddRemoveMultipleView(habit: habit, viewModel: viewModel)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Material.thickMaterial)
                                .shadow(color: .black.opacity(0.2), radius: 8)
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: 500)
                        .padding()
                        .zIndex(2)
                        .transition(scaleTransition)
                }
                
                if quickAddViewShown {
                    QuickAddView(viewIsShown: $quickAddViewShown, habit: habit, shownDate: viewModel.shownDate)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(Material.thickMaterial)
                                .shadow(color: .black.opacity(0.2), radius: 8)
                        )
                        .frame(maxWidth: 500, maxHeight: geo.size.height - 100)
                        .padding()
                        .zIndex(3)
                        .transition(scaleTransition)
                }
                
            }
            .onAppear {
                viewModel.appViewModel = appViewModel
            }
            .habitDeleteAlert(isPresented: $deleteHabitAlertActive, habit: habit, context: viewContext, dismiss: dismiss)
        }
    }
}

struct ScrollCalendarDateView: View {
    let dateNumber: Int
    
    func getSpecificDate(value: Int, format: String) -> String {
        let currentDate = Date()
        let specificDate = Calendar.defaultCalendar.date(byAdding: .day, value: -value, to: currentDate)
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: specificDate!)
    }
    
    var body: some View {
        VStack {
            Text(getSpecificDate(value: dateNumber, format: "dd"))
                .font(.headline)
            Text(getSpecificDate(value: dateNumber, format: "MMM"))
                .font(.body).fontWeight(.light)
        }
        .padding(5)
        .background(Color(red: 236 / 255, green: 47 / 255, blue: 75 / 255))
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct NewHabitDetailView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
            NavigationView {HabitDetailView(habit: HabitItem.testHabit, listViewModel: ListViewModel())
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
                .environmentObject(UserSettings())
                .environmentObject(AppViewModel())
            }.previewDevice("iPhone 12")
            
//            NavigationView {
//                Text("Test")
//
//                HabitDetailView(habit: habit, listViewModel: ListViewModel())
//                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//                .environmentObject(UserSettings())
//                .environmentObject(AppViewModel())
//            }.previewDevice("iPad Pro (12.9-inch) (5th generation)").previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
