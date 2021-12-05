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
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject private var userSettings: UserSettings
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.colorScheme) var colorScheme
    
    init(habit: HabitItem) {
        self.habit = habit
        
        switch habit.resetIntervalEnum {
        case .daily:
            habitIntervalString = "day"
        case .weekly:
            habitIntervalString = "week"
        case .monthly:
            habitIntervalString = "month"
        }
        
        self._viewModel = StateObject(wrappedValue: HabitDetailViewModel(habit: habit))
    }
    
    @StateObject private var viewModel: HabitDetailViewModel
    
    var habitIntervalString: String
    
    var habitAmountText: String {
        switch habit.valueTypeEnum {
        case .number:
            return "\(viewModel.habit.relevantCount(viewModel.shownDate))/\(habit.amountToDo)"
        default:
            return "\(viewModel.habit.relevantCount(viewModel.shownDate))\(habit.valueTypeEnum.unit)"
        }
    }
    
    
    @ObservedObject var habit: HabitItem
    
    var habitCircle: some View {
        GeometryReader { geo in
            ZStack {
                ProgressBar(strokeWidth: 30, progress: viewModel.progress(), color: habit.iconColor)
                    .frame(maxWidth: .infinity)
                    .padding(25)
                    .drawingGroup()
                    
                
                HStack {
                    Button(action: viewModel.removeFromHabit) {
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
                    
                    VStack {
                        Text(habitAmountText)
                            .font(.system(size: 40, weight: .black, design: .monospaced))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 10)
                        Text("for this \(habitIntervalString)")
                            .font(.headline.weight(.light))
                    }
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.15)) {
                            viewModel.multipleAddShown = true
                        }
                    }
                    
                    Button(action: viewModel.addToHabit) {
                        Image(systemName: "plus.circle.fill")
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
                    .keyboardShortcut("+", modifiers: [.command])
                }
                //.padding(.horizontal, 50)
            }
            .frame(maxWidth: .infinity)
        .padding(.top)
        }
        .padding(.horizontal)
    }
    
    var multipleAdd: some View {
        ZStack {
//            RoundedRectangle(cornerRadius: 15)
//                .foregroundColor(Color("systemGray6"))
//                .shadow(color: .black.opacity(0.3), radius: 8)
            
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(.clear)
                .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 15))
                .shadow(color: .black.opacity(0.3), radius: 8)
            
            VStack {
                Picker("Add or Remove?", selection: $viewModel.multipleAddSelection) {
                    Text("Add").tag(MultipleAddEnum.add)
                    Text("Remove").tag(MultipleAddEnum.remove)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Text("How much?")
                    .font(.headline)
                    .padding(.top)
                
                ZStack(alignment: .trailing) {
                    TextField("Enter a number", text: $viewModel.multipleAddField)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit {
                            viewModel.addRemoveMultiple()
                        }
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    #endif
                    
                    Button {
                        viewModel.addRemoveMultiple()
                    } label: {
                        Image(systemName: "checkmark")
                            .imageScale(.medium)
                            .padding(.trailing)
                    }
                }
            }
            .padding(.horizontal)
        }
        .aspectRatio(2, contentMode: .fit)
        .padding(.horizontal, 30)
        .transition(.asymmetric(insertion: .scale.animation(.interpolatingSpring(stiffness: 450, damping: 28)), removal: .scale))
        .animation(.easeInOut, value: true)
    }
    
//    @State private var multipleAddSelection = MultipleAddEnum.add
//    @State private var multipleAddField = ""
//    @State private var multipleAddShown = false
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                if habit.habitDescription != nil {
                    HStack {
                        Text(habit.habitDescription!)
                            .padding(20)
                        Spacer()
                    }
                }
                
//                HStack {
//                    ForEach(habit.wrappedTags, id: \.id) { tag in
//                        Text(tag.wrappedName)
//                    }
//                }
                
                habitCircle
                    .frame(minWidth: 0, maxWidth: .infinity)
                
                Spacer()
                
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
                        .padding()
                }
                .padding()
                
                //NavigationLink("Graph", destination: HabitCompletionGraph(habit: habit))
            
            }
            #if os(iOS)
            .navigationBarTitle(habit.habitName, displayMode: .large)
            #endif
            .toolbar(content: {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(role: .destructive) {
                            withAnimation(.easeInOut) {
                                viewModel.deleteActionSheet = true
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button(action: {
                            viewModel.editSheet = true
                        }) {
                            Label("Edit", systemImage: "pencil")
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
            }
            .sheet(isPresented: $viewModel.graphSheet) {
                HabitSpecificGraphsView(habit: habit)
                    .accentColor(userSettings.accentColor)
            }
            .alert(isPresented: $viewModel.deleteActionSheet) {
                Alert(title: Text("Do you really want to delete this habit?"), primaryButton: .destructive(Text("Delete")) {
                    let request: NSFetchRequest<HabitItem> = HabitItem.fetchRequest()
                    request.fetchLimit = 1
                    request.predicate = NSPredicate(format: "%@ == id", habit.id as CVarArg)
                    do {
                        let habits = try viewContext.fetch(request)
                        print(habits)
                        for object in habits {
                            viewContext.delete(object)
                        }
                        
                        try viewContext.save()
                    } catch {
                        fatalError()
                    }
                }, secondaryButton: .cancel())
            }
            .zIndex(1)
            .blur(radius: viewModel.multipleAddShown ? 10 : 0)
            .contentShape(Rectangle())
            .onTapGesture {
                if viewModel.multipleAddShown {
                    withAnimation(.easeOut(duration: 0.15)) {
                        viewModel.multipleAddShown = false
                    }
                }
            }
            
            if viewModel.multipleAddShown {
                multipleAdd
                    .zIndex(2)
                    .padding(.top, 50)
            }
            
        }
        .ignoresSafeArea(.keyboard)
        
    }
}

struct ScrollCalendarDateView: View {
    let dateNumber: Int
    
    func getSpecificDate(value: Int, format: String) -> String {
        let currentDate = Date()
        let specificDate = Calendar.current.date(byAdding: .day, value: -value, to: currentDate)
        
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
        
        return NavigationView {HabitDetailView(habit: habit)
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }.previewDevice("iPhone 12")
    }
}
