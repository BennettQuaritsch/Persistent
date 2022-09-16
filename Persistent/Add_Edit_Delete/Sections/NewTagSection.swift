//
//  NewTagSection.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 18.07.22.
//

import SwiftUI

struct NewTagSection: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.colorScheme) var colorScheme
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \HabitTag.name, ascending: true)]) var tags: FetchedResults<HabitTag>
    @Namespace var namespace
    
    @ObservedObject var viewModel: AddEditViewModel
    
    func tagIsContained(tag: HabitTag) -> Bool {
        viewModel.tagSelection.contains(tag.wrappedId)
    }
    
    @State private var isAdding: Bool = false
    
    @State private var tagName: String = ""
    @FocusState private var addTextFieldFocused: Bool
    
    @State private var tagToEdit: HabitTag?
    @State private var isEditing: Bool = false
    @FocusState private var editTextFieldFocused: Bool
    
    @ViewBuilder var addTagBody: some View {
        VStack {
            ZStack {
                HStack {
                    Spacer()
                    
                    Button {
                        self.tagName = ""
                        self.tagToEdit = nil
                        
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.75, blendDuration: 1)) {
                            isAdding = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .imageScale(.large)
                            .padding(7)
                            .background(Color.black.opacity(0.1), in: Circle())
                    }
                }
                
                Text("AddEditBase.Tags.AddNewTag")
                    .font(.title2.bold())
                    .transition(.move(edge: .leading).animation(.easeOut(duration: 1)))
                    .animation(.easeOut(duration: 1), value: isAdding)
            }
            .padding(.bottom)
            
            HStack {
                Text("AddEditBase.Tags.TextField.Header")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            
            TextField("AddEditBase.Tags.TextField.Body", text: $tagName, prompt: Text("AddEditBase.Tags.TextField.Body"))
                .focused($addTextFieldFocused)
                .padding(10)
                .background(Color.systemGray6, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
    }
    
    var backgroundColor: Color {
        colorScheme == .dark ? .black : .systemBackground
    }
    
    @ViewBuilder var editTagBody: some View {
        VStack {
            ZStack {
                HStack {
                    Spacer()
                    
                    Button {
                        self.tagName = ""
                        self.tagToEdit = nil
                        
                        withAnimation(.spring(response: 0.25, dampingFraction: 0.75, blendDuration: 1)) {
                            isEditing = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .font(.headline)
                            .imageScale(.large)
                            .padding(7)
                            .background(Color.black.opacity(0.1), in: Circle())
                    }
                }
                
                Text("AddEditBase.Tags.EditTag")
                    .font(.title2.bold())
            }
            .padding(.bottom)
            
            HStack {
                Text("AddEditBase.Tags.TextField.Header")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            
            TextField("AddEditBase.Tags.TextField.Body", text: $tagName, prompt: Text("AddEditBase.Tags.TextField.Body"))
                .focused($editTextFieldFocused)
                .padding(10)
                .background(Color.systemGray6, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
        }
    }
    
    var body: some View {
        VStack {
            if isAdding {
                ZStack {
                    backgroundColor
                        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                        
                    VStack {
                        addTagBody
                            
                        Spacer()
                        
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.75, blendDuration: 1)) {
                                addTag()
                            }
                        } label: {
                            HStack {
                                Text("AddEditBase.Tags.AddNewTag")
                                
                                Image(systemName: "plus")
                            }
                            .padding()
                            .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .font(.headline)
                            .foregroundColor(.white)
                            
                            
                        }
                    }
                    .padding()
                    
                }
                .transition(.popUpScaleTransition)
                .frame(height: 240)
                .padding()
            } else {
                if isEditing {
                    ZStack {
                        backgroundColor
                            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))

                        
                        VStack {
                            editTagBody
                            
                            Spacer()
                               
                            Button {
                                withAnimation(.spring(response: 0.25, dampingFraction: 0.75, blendDuration: 1)) {
                                    editTag()
                                    editTextFieldFocused = true
                                }
                            } label: {
                                HStack {
                                    Text("AddEditBase.Tags.EditTag")
                                    
                                    Image(systemName: "pencil")
                                }
                                .padding()
                                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                                .frame(maxWidth: .infinity)
                                .contentShape(Rectangle())
                                .font(.headline)
                                .foregroundColor(.white)
                            }
                        }
                        .padding()
                    }
                    .transition(.popUpScaleTransition)
                    .frame(height: 240)
                    .padding()
                } else {
                    
                    ScrollView() {
                        VStack(spacing: 10) {
                            ForEach(tags) { tag in
                                Button {
                                    if viewModel.tagSelection.contains(tag.wrappedId) {
                                        viewModel.tagSelection.remove(tag.wrappedId)
                                    } else {
                                        viewModel.tagSelection.insert(tag.wrappedId)
                                    }
                                } label: {
                                    HStack {
                                        Text(tag.wrappedName)
                                            .fontWeight(.semibold)
                                        
                                        Spacer()
                                        
                                        if tagIsContained(tag: tag) {
                                            Image(systemName: "checkmark")
                                                .imageScale(.medium)
                                                .foregroundColor(.accentColor)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 25)
                                    .padding()
                                    .background(Color.secondarySystemGroupedBackground, in: Capsule(style: .continuous))
                                }
                                .buttonStyle(.plain)
                                .contentShape(.contextMenuPreview, Capsule(style: .continuous))
                                .transition(.popUpScaleTransition)
                                .contextMenu {
                                    Button {
                                        tagToEdit = tag
                                        tagName = tag.wrappedName
                                        
                                        withAnimation(.standardSpringAnimation) {
                                            isEditing = true
                                        }
                                        
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            editTextFieldFocused = true
                                        }
                                    } label: {
                                        Label("General.Buttons.Edit", systemImage: "pencil")
                                    }
                                    
                                    Button(role: .destructive) {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            withAnimation {
                                                do {
                                                    let object = viewContext.object(with: tag.objectID)
                                                    viewContext.delete(object)
                                                    
                                                    try viewContext.save()
                                                } catch {
                                                    errorVibration()
                                                }
                                            }
                                        }
                                    } label: {
                                        Label("General.Buttons.Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
        .background(
            Color.systemGroupedBackground
                .edgesIgnoringSafeArea(.all)
        )
        .navigationTitle("AddEditBase.Tags.Header")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    if isEditing {
                        withAnimation(.standardSpringAnimation) {
                            isEditing = false
                            tagName = ""
                            tagToEdit = nil
                        }
                    }
                    
                    withAnimation(.standardSpringAnimation) {
                        isAdding = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        addTextFieldFocused = true
                    }
                } label: {
                    Label("AddEditBase.Tags.AddNewTag", systemImage: "plus")
                }
            }
        }
    }
}

extension NewTagSection {
    func addTag() {
        if !self.tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let newTag = HabitTag(context: viewContext)
            newTag.id = UUID()
            newTag.wrappedName = self.tagName
            
            viewModel.tagSelection.insert(newTag.wrappedId)

            self.tagName = ""
            self.isAdding = false
            
        } else {
            errorVibration()
        }
    }
    
    func editTag() {
        if !self.tagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, let tagToEdit {
            tagToEdit.wrappedName = tagName
            
            do {
                try viewContext.save()
            } catch {

            }

            self.tagName = ""
            self.isEditing = false
            self.tagToEdit = nil
        } else {
            errorVibration()
        }
    }
}

struct NewTagSectionPreviewContainer: View {
    var body: some View {
        NewTagSection(viewModel: AddEditViewModel())
    }
}

struct NewTagSection_Previews: PreviewProvider {
    @State private var test: Set<UUID> = []
    static var previews: some View {
        NavigationStack {
            NewTagSectionPreviewContainer()
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
        .previewDevice("iPhone 13 Pro")
        
        VStack {
            
        }
        .sheet(isPresented: .constant(true)) {
            NavigationStack {
                NewTagSectionPreviewContainer()
                    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            }
        }
        .previewDevice("iPad Pro (11-inch) (3rd generation)")
        .previewInterfaceOrientation(.landscapeLeft)
    }
}
