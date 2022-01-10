//
//  AddHabitView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 14.05.21.
//

import SwiftUI
import CoreData

struct AddHabitView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    @Environment(\.purchaseInfo) var purchaseInfo
    
    let accentColor: Color
    
    @StateObject private var viewModel: AddEditViewModel = AddEditViewModel()
    
    @FocusState private var valueTypeTextFieldSelected: Bool
    
    var body: some View {
        NavigationView {
            EditHabitBaseView(viewModel: viewModel, saveButtonAction: {
                viewModel.addHabit(viewContext: viewContext, dismiss: dismiss)
            })
            #if os(iOS)
            .navigationBarTitle("Create a Habit")
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        viewModel.addHabit(viewContext: viewContext, dismiss: dismiss)
                    } label: {
                        #if os(iOS)
                        Label("Save", systemImage: "plus")
                        #else
                        Text("Save")
                        #endif
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("Close")
                    }
                }
            }
        }
        .accentColor(accentColor)
    }
    
    var addHabitButton: some View {
        Button("Add your Habit") {
            viewModel.addHabit(viewContext: viewContext, dismiss: dismiss)
        }
    }
}

/// View for choosing Icons from a grid.
struct ChooseIconView: View {
    @Environment(\.presentationMode) var presentationMode
    
    let columns = [GridItem(.adaptive(minimum: 60, maximum: 80))]
    
    @Binding var iconChoice: String
    
    var body: some View {
        ZStack {
            Color("systemGray6")
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                ForEach(iconSections, id: \.self) { section in
                    HStack {
                        Text(section.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Spacer()
                    }
                    
                    LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                        ForEach(section.iconArray, id: \.self) { icon in
                            ZStack {
                                ZStack {
                                    Image(icon)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.primary.opacity(0.7))
                                        .padding(8)
                                        .accessibility(label: Text(icon))
                                    
                                    //Color.primary.blendMode(.sourceAtop)
                                }
                                .onTapGesture {
                                    iconChoice = icon
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationTitle("Choose Icon")
    }
}

struct AddHabitView_Previews: PreviewProvider {
    static var previews: some View {
        AddHabitView(accentColor: Color.accentColor)
            .previewDevice("iPhone 12")
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
