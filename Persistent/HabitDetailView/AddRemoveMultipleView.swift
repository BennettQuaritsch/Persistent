//
//  AddRemoveMultipleView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 05.05.22.
//

import SwiftUI

struct AddRemoveMultipleView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @FocusState private var textFieldFocused: Bool
    
    @ObservedObject var habit: HabitItem
    @ObservedObject var viewModel: HabitDetailView.HabitDetailViewModel
    
    var springAnimation: Animation = .spring(response: 0.25, dampingFraction: 0.6, blendDuration: 1)
    
    var body: some View {
        VStack {
//            HStack {
//                Spacer()
//                
//                Button {
//                    withAnimation(springAnimation) {
//                        viewModel.multipleAddShown = false
//                    }
//                } label: {
//                    Image(systemName: "xmark")
//                        .font(.headline)
//                        .imageScale(.large)
//                        .padding(7)
//                        .background(Color.black.opacity(0.1), in: Circle())
//                }
//                .accessibilityLabel("General.Buttons.Close")
//            }
//            
//            Text("DetailView.AddRemoveMultiple.Header")
//                .font(.title2.weight(.semibold))
            
            ZStack {
                Text("DetailView.AddRemoveMultiple.Header")
                    .font(.title2.weight(.semibold))
                
                HStack {
                    Spacer()
                    
                    Button {
                        withAnimation(springAnimation) {
                            viewModel.multipleAddShown = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .imageScale(.large)
                            .padding(7)
                            .background(Color.black.opacity(0.1), in: Circle())
                    }
                    .accessibilityLabel("General.Buttons.Close")
                }
            }
            
            Picker("DetailView.AddRemoveMultiple.Picker.Header", selection: $viewModel.multipleAddSelection) {
                Text("DetailView.AddRemoveMultiple.Picker.Add").tag(HabitDetailView.MultipleAddEnum.add)
                Text("DetailView.AddRemoveMultiple.Picker.Remove").tag(HabitDetailView.MultipleAddEnum.remove)
            }
            .pickerStyle(.segmented)
            
            Text("DetailView.AddRemoveMultiple.HowMuch")
                .font(.headline)
                .padding(.top)
            
            ComparableHabitTypesPicker(habit: habit, selection: $viewModel.selectedHabitTypeForMultipleAdd)
            
            ZStack(alignment: .trailing) {
                TextField("DetailView.AddRemoveMultiple.TextField", text: $viewModel.multipleAddField)
                    .textFieldStyle(.roundedBorder)
                    .focused($textFieldFocused)
                    .onSubmit {
                        viewModel.addRemoveMultiple(context: viewContext, fieldAnmation: springAnimation)
                        habit.objectWillChange.send()
                    }
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                
                Button {
                    viewModel.addRemoveMultiple(context: viewContext, fieldAnmation: springAnimation)
                } label: {
                    Image(systemName: "checkmark")
                        .imageScale(.large)
                        .font(.headline)
                        .padding(.trailing)
                }
                .accessibilityLabel("General.Buttons.Submit")
                .accessibilityAddTraits(.isButton)
                .accessibilityRemoveTraits(.isStaticText)
            }
        }
        .padding()
        .onAppear {
            textFieldFocused = true
        }
        .onDisappear {
            textFieldFocused = false
        }
    }
}

struct AddRemoveMultipleView_Previews: PreviewProvider {
    static var previews: some View {
        AddRemoveMultipleView(habit: .testHabit, viewModel: .init(habit: .testHabit))
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Material.thickMaterial)
                    .shadow(color: .black.opacity(0.2), radius: 8)
            )
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: 500)
    }
}
