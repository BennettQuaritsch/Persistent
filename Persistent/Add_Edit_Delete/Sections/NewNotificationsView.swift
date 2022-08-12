//
//  NewNotificationsView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 02.12.21.
//

import SwiftUI

struct NewNotificationsView: View {
    @ObservedObject var viewModel: NewNotificationsViewModel
    var body: some View {
        ScrollView {
            VStack {
                ForEach($viewModel.notifcationArray) { $notificationDate in
                    VStack {
                        HStack {
                            TextField("Message for your notification", text: $notificationDate.message, prompt: Text("Message"), axis: .vertical)
                                .lineLimit(...3)
                                .padding(6)
                                .background(Color(UIColor.quaternarySystemFill), in: RoundedRectangle(cornerRadius: 9, style: .continuous))
                            
                            DatePicker("Select a time", selection: $notificationDate.date, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        
                        NewChooseWeekView(notificationDate: $notificationDate)
                    }
                    .transition(.popUpScaleTransition)
                    .padding(10)
                    .background(Color.systemBackground, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .contextMenu {
                        Button(role: .destructive) {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation {
                                    viewModel.notifcationArray.removeAll(where: { $0.id == notificationDate.id })
                                }
                            }
                        } label: {
                            Label("Delete Notification", systemImage: "trash")
                                .labelStyle(.iconOnly)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.systemGroupedBackground, ignoresSafeAreaEdges: .all)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    withAnimation {
                        viewModel.notifcationArray.append(.init(message: "", date: Date(), weekdays: [getDateIndex()]))
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func getDateIndex() -> Int {
        let cal = Calendar.defaultCalendar
//        let prefLanguage = Locale.preferredLanguages[0]
//        cal.locale = .init(identifier: prefLanguage)
        
        var weekday = (cal.component(.weekday, from: Date()) - 1) - (cal.firstWeekday - 1)
        
        while weekday < 0 {
            weekday += 7
        }
        
        return weekday + 1
    }
}

struct NewNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NewNotificationsView(viewModel: NewNotificationsViewModel())
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }

    }
}
