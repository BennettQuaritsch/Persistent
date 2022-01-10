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
        List {
            ForEach($viewModel.notifcationArray) { $notificationDate in
                VStack {
                    HStack {
                        TextField("Notification name", text: $notificationDate.message, prompt: Text("Name your notification"))
                        
                        DatePicker("Select a time", selection: $notificationDate.date, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    
                    NewChooseWeekView(notificationDate: $notificationDate)
                    
                }
                .frame(height: 90)
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        withAnimation {
                            if let index = viewModel.notifcationArray.firstIndex(where: { $0.id == notificationDate.id }) {
                                viewModel.notifcationArray.remove(at: index)
                            }
                        }
                    } label: {
                        Label("Delete Notification", systemImage: "trash")
                            .labelStyle(.iconOnly)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    withAnimation {
                        viewModel.notifcationArray.append(.init(message: "Notification", date: Date(), weekdays: [getDateIndex()]))
                    }
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
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
        NewNotificationsView(viewModel: NewNotificationsViewModel())
    }
}
