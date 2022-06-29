//
//  QuickAddView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 28.02.22.
//

import SwiftUI

struct QuickAddView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var appViewModel: AppViewModel
    
    @Binding var viewIsShown: Bool
    
    @ObservedObject var habit: HabitItem
    
    @State var selectedTypeValue: HabitValueTypes = .number
    
    @Namespace var namespace
    @State var isAdding: Bool = false
    
    var shownDate: Date
    
    @State private var addingName: String = ""
    @State private var addingValue: String = ""
    
    var animation: Animation = .spring(response: 0.25, dampingFraction: 0.7, blendDuration: 1)
    
    let habitAddAnimation: Animation = .easeOut
    
    let springAnimation: Animation = .spring(response: 0.25, dampingFraction: 0.6, blendDuration: 1)
    var scaleTransition: AnyTransition {
        return .asymmetric(insertion: .scale(scale: 0.4)
            .animation(springAnimation), removal: .scale(scale: 0.4)
            .animation(.easeIn(duration: 0.12)))
            .combined(with: .opacity)
    }
    
    @State private var forEachSize: CGSize = .zero
    
    @FocusState private var focusedField: QuickAddFocusStateEnum?
    
    var body: some View {
        VStack {
            
            ZStack {
                Text("Quick Add Actions")
                    .font(.title2.weight(.semibold))
                
                HStack {
                    Spacer()
                    
                    Button {
                        withAnimation(springAnimation) {
                            viewIsShown = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .imageScale(.large)
                            .padding(7)
                            .background(Color.black.opacity(0.1), in: Circle())
                    }
                }
            }
            
            if !habit.quickAddActionsArray.isEmpty {
                ScrollView(showsIndicators: false) {
                    ForEach(habit.quickAddActionsArray) { quickAddAction in
                        HStack(spacing: 0) {
                            Text(quickAddAction.wrappedName)
                                .font(.headline)
                                .foregroundColor(.systemBackground)
                            
                            Spacer()
                            
                            ZStack {
                                Capsule(style: .continuous)
                                    .fill(habit.iconColor)
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: -4, y: 0)
                                
                                HStack(spacing: 5) {
//                                    Text("Add")
                                    
                                    Text("\(quickAddAction.valueStringFormatted())")
                                        .font(.headline)
                                }
                                .padding(.horizontal)
                            }
                            .fixedSize(horizontal: true, vertical: false)
                            .foregroundColor(.systemBackground)
                        }
                        .padding(.leading)
                        .frame(height: 50)
                        .background(habit.iconColor.opacity(0.8), in: Capsule(style: .continuous))
                        .transition(.opacity.animation(.easeOut(duration: 0.1)))
                        .contentShape(ContentShapeKinds.contextMenuPreview, Capsule(style: .continuous))
                        .onTapGesture {
                            addValueToHabit(quickAddAction: quickAddAction)
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                withAnimation(.easeOut(duration: 0.1)) {
                                    viewContext.delete(quickAddAction)
                                    
                                    do {
                                        try viewContext.save()
                                    } catch {
                                        print("Error")
                                        
                                        let nsError = error as NSError
                                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                                    }
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .overlay(
                        GeometryReader { geo in
                            Color.clear.onAppear {
                                forEachSize = geo.size
                            }
                            .onChange(of: habit.quickAddActionsArray.count) { _ in
                                withAnimation(animation) {
                                    forEachSize = geo.size
                                }
                            }
                        }
                    )
                    
                }
                .frame(maxHeight: isAdding ? min(forEachSize.height, 200) : forEachSize.height)
//                .fixedSize(horizontal: false, vertical: true)
                .padding(.bottom)
                
            }
            
            // New-QuickAddAction View
            HStack {
                if isAdding {
                    VStack(alignment: .leading) {
                        TextField("Name", text: $addingName)
                            .textFieldStyle(.roundedBorder)
                            .foregroundColor(.primary)
                            .focused($focusedField, equals: .name)
                            .onSubmit {
                                focusedField = .amount
                            }
                            .overlay(alignment: .trailing) {
                                Image(systemName: "textformat.abc")
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 5)
                            }
                        
                        ComparableHabitTypesPicker(habit: habit, selection: $selectedTypeValue)
                        
                        TextField("Amount", text: $addingValue)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .foregroundColor(.primary)
                            .focused($focusedField, equals: .amount)
                            .onSubmit {
                                focusedField = nil
                                
                                addQuickAddAction()
                            }
                            .overlay(alignment: .trailing) {
                                Image(systemName: "textformat.123")
                                    .foregroundColor(.secondary)
                                    .padding(.trailing, 5)
                            }
                    }
                    .padding(.vertical)
                    .transition(.move(edge: .leading))
                    
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .padding(5)
                        .frame(width: 40)
                        .rotationEffect(.degrees(isOneEmpty ? 45 : 0))
                        .animation(animation, value: isOneEmpty)
                        .matchedGeometryEffect(id: "plus", in: namespace)
                        .onTapGesture {
                            addQuickAddAction()
                            
                            focusedField = nil
                        }
                } else {
                    HStack {
                        Image(systemName: "plus")
                            .matchedGeometryEffect(id: "plus", in: namespace)
                        
                        Text("Create new quick add")
                            .transition(AnyTransition.move(edge: .trailing).animation(animation))
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        withAnimation(animation) {
                            isAdding.toggle()
                        }
                        
                        focusedField = .name
                    }
                }
            }
            .foregroundColor(.systemBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            .frame(maxWidth: .infinity, minHeight: 50)
            .fixedSize(horizontal: false, vertical: true)
            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .padding()
        .onAppear {
            selectedTypeValue = habit.valueTypeEnum
        }
    }
}

extension QuickAddView {
    enum QuickAddFocusStateEnum: Hashable {
        case name, amount
    }
    
    func resetValues() {
        addingName = ""
        addingValue = ""
    }
    
    func addValueToHabit(quickAddAction: HabitQuickAddAction) {
        withAnimation(habitAddAnimation) {
            habit.addToHabit(quickAddAction.wrappedValue, date: shownDate, context: viewContext, appViewModel: appViewModel)
            habit.objectWillChange.send()
        }
        
        withAnimation(springAnimation) {
            viewIsShown = false
        }
        
        selectionChangedVibration()
    }
    
    func addQuickAddAction() {
        withAnimation(animation) {
            isAdding.toggle()
        }
        
        guard !addingName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            resetValues()
            
            errorVibration()
            
            return
        }
        
        guard let number = numberFormatter.number(from: addingValue) else {
            resetValues()
            
            errorVibration()
            
            return
        }
//        var int: Int32
//
//        switch habit.valueTypeEnum {
//        case .volumeLitres:
//            int = Int32(number.doubleValue * 1000)
//        default:
//            int = number.int32Value
//        }
        
        HabitQuickAddAction.newQuickAddActionForValueType(
            selectedValueType: selectedTypeValue,
            id: UUID(),
            name: addingName,
            value: number,
            habit: habit,
            context: viewContext
        )
        
//        let newQuickAddAction = HabitQuickAddAction(context: viewContext)
//        newQuickAddAction.id = UUID()
//        newQuickAddAction.wrappedName = addingName
//        newQuickAddAction.wrappedValueAdjustedForValueType(number: number, habit: habit)
//        newQuickAddAction.habit = habit
//
//        do {
//            try viewContext.save()
//        } catch {
//            print("Error")
//
//            let nsError = error as NSError
//            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//        }
        
        resetValues()
    }
    
    var numberFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }
    
    var isOneEmpty: Bool {
        return addingName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || addingValue.isEmpty
    }
    
    func errorVibration() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}

struct QuickAddView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            QuickAddView(viewIsShown: .constant(true), habit: HabitItem.testHabit, shownDate: Date())
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 30, style: .continuous))
                .padding()
        }
    }
}
