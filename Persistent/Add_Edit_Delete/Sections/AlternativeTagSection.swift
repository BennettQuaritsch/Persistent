//
//  AlternativeTagSection.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 07.09.21.
//

import SwiftUI

struct AlternativeTagSection: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: HabitTag.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HabitTag.name, ascending: true)]) var tags: FetchedResults<HabitTag>
    
    @State private var test: [HabitTag] = []
    @State private var isEditing: Bool = false
    
    @Binding var selectedTags: Set<UUID>
    
    var body: some View {
        List {
            ForEach(tags, id: \.id) { tag in
                TagDetail(tag: tag, isEditing: $isEditing, selectedTags: $selectedTags)
            }
            .onDelete(perform: deleteTagWithOffset)
        }
        .onAppear {
            print(selectedTags)
        }
        .listStyle(InsetGroupedListStyle())
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    isEditing.toggle()
                    print(isEditing)
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                
                Button {
                    let newTag = HabitTag(context: PersistenceController.shared.container.viewContext)
                    
                    newTag.id = UUID()
                    newTag.name = "Untitled Tag"
                    
                    test.append(newTag)
                    
                    do {
                        try PersistenceController.shared.container.viewContext.save()
                    } catch {
                        fatalError()
                    }
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationBarTitle("Choose Tags")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func deleteTagWithOffset(at offsets: IndexSet) {
        for index in offsets {
            viewContext.perform {
                let tag = tags[index]
                tag.deleteTag()
                
                do {
                    try viewContext.save()
                } catch {
                    fatalError()
                }
            }
        }
    }
}

struct TagDetail: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var tag: HabitTag
    
    @Binding var isEditing: Bool
    
    @Binding var selectedTags: Set<UUID>
    
    var body: some View {
        //TextField("", text: $tag.wrappedName)
        if isEditing {
            HStack {
                TextField("Enter a name", text: $tag.wrappedName)
                    .padding(3)
                    .onDisappear {
                        do {
                            try viewContext.save()
                        } catch {
                            fatalError()
                        }
                }
            }
        } else {
            HStack {
                Text(tag.wrappedName)
                    .padding(3)
                
                Spacer()
                
                if selectedTags.contains(tag.wrappedId) {
                    Image(systemName: "checkmark.circle")
                } else {
                    Image(systemName: "circle")
                }
            }
            .onTapGesture {
                if selectedTags.contains(tag.wrappedId) {
                    selectedTags.remove(tag.wrappedId)
                } else {
                    selectedTags.insert(tag.wrappedId)
                }
            }
        }
    }
}

struct AlternativeTagSection_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AlternativeTagSection(selectedTags: .constant(Set<UUID>()))
        }
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

var testTags: [HabitTag] {
    var array: [HabitTag] = []
    for i in 0..<10 {
        let newTag = HabitTag(context: PersistenceController.shared.container.viewContext)
        
        newTag.id = UUID()
        newTag.name = "Tag \(i)"
        
        array.append(newTag)
    }
    return array
}
