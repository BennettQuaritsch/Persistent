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
    @Environment(\.interfaceColor) var interfaceColor
    
    init(habit: HabitItem, habitToEdit: Binding<HabitItem?>) {
        self.habit = habit
        
        self._viewModel = ObservedObject(wrappedValue: HabitDetailViewModel(habit: habit))
        self._habitTimer = StateObject(wrappedValue: HabitTimer(habit: habit))
        
        self._habitToEdit = habitToEdit
    }
    
    @ObservedObject private var viewModel: HabitDetailViewModel
    @StateObject private var editViewModel: EditViewShownModel = EditViewShownModel()
    
    @State private var showCalendarSheet: Bool = false
//    @ObservedObject private var listViewModel: ListViewModel
    
    @FocusState private var multipleAddViewTextFieldFocused: Bool
    
    @ObservedObject var habit: HabitItem
    
    @Binding var habitToEdit: HabitItem?
    
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
                .accessibilityLabel("DetailView.Accessibility.Button.RemoveFromHabit")
                
                Spacer()
                
                Text(verbatim: habit.relevantCountText(viewModel.shownDate))
                    .font(.system(size: horizontalSizeClass == .regular ? 45 : 35, weight: .black, design: .rounded))
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
                    .multilineTextAlignment(.center)
                    .monospacedDigit()
                    .padding(.horizontal, 5)
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                    .frame(minWidth: 30)
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
                .accessibilityLabel("DetailView.Accessibility.Button.AddToHabit")
            }
            .padding(.horizontal, parentSizeClass == .compact ? 60 : 70)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
    
    @State private var quickAddViewShown: Bool = false
    @State private var statisticsViewShown: Bool = false
    
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
                
                Text("DetailView.QuickAdd.Button")
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
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                    .padding(.top)
                    .layoutPriority(10)
                    
                    Text("DetailView.GoalString \(habit.amountToDoString()) \(NSLocalizedString(habit.resetIntervalEnum.nounLocalizedStringKey, comment: ""))")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 5)
                    
                    Spacer()
                        .frame(minHeight: parentSizeClass == .regular ? 0 : 10, maxHeight: 20)
                        .layoutPriority(0)
                    
                    habitCircle
                        .frame(minWidth: 150, maxWidth: .infinity)
                        .layoutPriority(10)
                    
                    Spacer()
                        .frame(minHeight: parentSizeClass == .regular ? 20 : 10)
                        .layoutPriority(0)
                    
                    ViewThatFits(in: .vertical) {
                        VStack {
                            QuickAddViewButton
                            
                            Spacer()
                                .frame(minHeight: parentSizeClass == .regular ? 10 : 0, maxHeight: 10)
                                .layoutPriority(-1)
                            
                            HStack {
                                graphsViewButton
                                
                                calendarViewButton
                            }
                        }
                        
                        HStack {
                            graphsViewButton
                            
                            QuickAddViewButton
                            
                            calendarViewButton
                            
                        }
                    }
                    .layoutPriority(2)
                    
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
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        let content = ShareProgressCircleView(habit: habit, date: viewModel.shownDate)
                        if let cgimage = ImageRenderer(content: content).cgImage {
                            let image = Image(cgimage, scale: 1, label: Text("My Progress"))

                            ShareLink(
                                item: image,
                                preview: SharePreview("Share your progress!", image: image))
                        }
//
//
                        Menu {
                            Section {
                                Button(action: {
                                    viewModel.multipleAddShown = true
                                    
                                    multipleAddViewTextFieldFocused = true
                                }) {
                                    Label("DetailView.Menu.AddRemoveMultiple", systemImage: "plus.forwardslash.minus")
                                }
                            }
                            
                            Section {
                                Button(action: {
                                    habitToEdit = habit
                                }) {
                                    Label("General.Buttons.Edit", systemImage: "pencil")
                                }
                                .accessibilityIdentifier("MenuEditButton")
                            }
                            
                            Section {
                                Button {
                                    withAnimation {
                                        if habit.habitArchived {
                                            habit.unarchiveHabit(context: viewContext)
                                        } else {
                                            habit.archiveHabit(context: viewContext)
                                        }
                                    }
                                } label: {
                                    if habit.habitArchived {
                                        Label("General.Buttons.Unarchive", systemImage: "archivebox")
                                    } else {
                                        Label("General.Buttons.Archive", systemImage: "archivebox")
                                    }
                                }
                                
                                Button(role: .destructive) {
                                    withAnimation(.easeInOut) {
                                        deleteHabitAlertActive = true
                                    }
                                } label: {
                                    Label("General.Buttons.Delete", systemImage: "trash")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                        }
                        .accessibilityLabel("DetailView.Accessibility.Menu")
                        .accessibilityIdentifier("DetailMenu")
                    }
                })
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
                .accessibilityHidden(viewModel.multipleAddShown || quickAddViewShown)
                
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
        .sheet(isPresented: $editViewModel.editSheet) {
            AddHabitView(accentColor: userSettings.accentColor)
                .environment(\.managedObjectContext, self.viewContext)
                .environment(\.purchaseInfo, purchaseInfo)
                .environment(\.interfaceColor, interfaceColor)
        }
        .sheet(isPresented: $showCalendarSheet) {
            CalendarPageViewController(
                toggle: $showCalendarSheet,
                habitDate: $viewModel.shownDate,
                date: Date(),
                habit: habit
            )
//            .presentationDetents([.height(550)])
                .accentColor(userSettings.accentColor)
                .environment(\.horizontalSizeClass, horizontalSizeClass)
                .environment(\.colorScheme, colorScheme)
                .environment(\.parentSizeClass, parentSizeClass)
        }
        .sheet(isPresented: $statisticsViewShown) {
            HabitSpecificGraphsView(habit: habit)
//            HabitStatisticsView(habit: habit)
                .accentColor(userSettings.accentColor)
                .environment(\.purchaseInfo, purchaseInfo)
        }
        .alert(isPresented: $viewModel.deleteActionSheet) {
            Alert(title: Text("Do you really want to delete this habit?"), primaryButton: .destructive(Text("Delete")) {
                habit.deleteHabitPermanently()
            }, secondaryButton: .cancel())
        }
    }
}

extension HabitDetailView {
    @ViewBuilder var graphsViewButton: some View {
        Button {
            statisticsViewShown = true
        } label: {
            Circle()
                .scaledToFit()
                .foregroundColor(.accentColor)
                .overlay(
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 25))
                        .foregroundColor(.init("systemBackground"))
                )
                .frame(height: 50)
                .hoverEffect(.lift)
                .padding()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Graphs")
        .accessibilityIdentifier("GraphsButton")
    }
    
    @ViewBuilder var calendarViewButton: some View {
        Button {
            showCalendarSheet = true
        } label: {
            Circle()
                .scaledToFit()
                .foregroundColor(.accentColor)
                .overlay(
                    Image(systemName: "calendar")
                        .font(.system(size: 25))
                        .foregroundColor(.init("systemBackground"))
                )
                .frame(height: 50)
                .hoverEffect(.lift)
                .padding()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Calendar")
    }
}

struct NewHabitDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HabitDetailView(habit: HabitItem.testHabit, habitToEdit: .constant(nil))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(UserSettings())
            .environmentObject(AppViewModel())
        }
        .previewDevice("iPhone 13 mini")
        
        NavigationStack {
            HabitDetailView(habit: HabitItem.testHabit, habitToEdit: .constant(nil))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(UserSettings())
            .environmentObject(AppViewModel())
        }
        .previewDevice("iPhone SE (3rd generation)")
        .previewDisplayName("iPhone SE")
    }
}
