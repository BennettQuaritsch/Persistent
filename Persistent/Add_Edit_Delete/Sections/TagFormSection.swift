//
//  TagFormSection.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 04.09.21.
//

import SwiftUI
import CoreData

struct TagFormSection: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(entity: HabitTag.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HabitTag.name, ascending: true)]) var tags: FetchedResults<HabitTag>
    
    @State var isAdding: Bool = false
    @State var tagName: String = ""
    @State var tagEditUUID: UUID?
    
    @Binding var selection: Set<UUID>
    
    @Namespace private var animation
    
    func selectionChanged() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    var body: some View {
        HStack(alignment: .center) {
            if isAdding {
                ZStack {
                    Capsule()
                        .fill(Color(UIColor.tertiarySystemGroupedBackground))
                        .matchedGeometryEffect(id: "buttonBackground", in: animation)
                    
                    HStack {
                        Image(systemName: "plus")
                            .matchedGeometryEffect(id: "button", in: animation)
                            .padding()
                            .onTapGesture(perform: saveAddTag)
                        
                        TextField("Create a tag", text: $tagName)
                        
                        Image(systemName: "trash")
                            .padding()
                            .onTapGesture(perform: toggleAddTag)
                    }
                }
            }
            
            if !isAdding {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(tags, id: \.id) { tag in
                            Text(tag.name ?? "")
                                .padding()
                                .background(
                                    Capsule()
                                        .fill(Color(selection.contains(tag.id ?? UUID()) ?  UIColor.systemGray4 : UIColor.systemGray6))
                                )
                                .onTapGesture {
                                    if selection.contains(tag.id ?? UUID()) {
                                        selection.remove(tag.id ?? UUID())
                                    } else {
                                        selection.insert(tag.id ?? UUID())
                                    }
                                    
                                    selectionChanged()
                                }
                                
                        }
                    }
//                    HStack {
//                        ForEach(0..<100) { num in
//                            Text("\(num)")
//                                .tagSelectionBackground()
//                        }
//                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .transition(.move(edge: .leading).animation(.easeOut(duration: 0.1)).combined(with: .opacity))
            }
            
            if !isAdding {
                ZStack {
                    Capsule()
                        .fill(Color(UIColor.tertiarySystemGroupedBackground))
                        .aspectRatio(contentMode: .fit)
                        .matchedGeometryEffect(id: "buttonBackground", in: animation)
                    
                    Image(systemName: "plus")
                        .matchedGeometryEffect(id: "button", in: animation)
                        .onTapGesture(perform: toggleAddTag)
                }
            }
        }
        .frame(height: 50)
    }
    
    func saveAddTag() {
        withAnimation(.interpolatingSpring(stiffness: 375, damping: 27)) {
            isAdding.toggle()
        }
        
        if let id = tagEditUUID {
            if let tag = tags.first(where: { $0.id == id }) {
                tag.name = tagName
            }
        } else {
            let newTag = HabitTag(context: viewContext)
            newTag.name = tagName
            newTag.id = UUID()
        }
        
        tagName = ""
        tagEditUUID = nil
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func toggleAddTag() {
        withAnimation(.interpolatingSpring(stiffness: 375, damping: 29)) {
            isAdding.toggle()
        }
        
        if let id = tagEditUUID {
            tagName = tags.first(where: { $0.id == id })?.name ?? ""
        } else {
            tagName = ""
        }
    }
}

struct TagSelectionBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                Capsule()
                    .fill(Color(UIColor.systemGroupedBackground))
            )
    }
}

extension View {
    func tagSelectionBackground() -> some View {
        self.modifier(TagSelectionBackgroundModifier())
    }
}

struct TagFormSection_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    static var previews: some View {
        var testHabit: HabitItem {
        
            let testItem: HabitItem = HabitItem(context: moc)
            testItem.habitName = "Test"
            testItem.amountToDo = 3
            testItem.resetIntervalEnum = .monthly
            
            let anotherNewItem = HabitCompletionDate(context: moc)
            anotherNewItem.date = Date()
            
            let secondNewItem = HabitCompletionDate(context: moc)
            secondNewItem.date = Date()
            testItem.date = NSSet(array: [anotherNewItem, secondNewItem])
            
            return testItem
        }
        return VStack{TagFormSection(selection: .constant(Set<UUID>()))}
            .previewLayout(.sizeThatFits)
    }
}
