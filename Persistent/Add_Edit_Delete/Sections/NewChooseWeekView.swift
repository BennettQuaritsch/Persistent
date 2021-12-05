//
//  NewChooseWeekView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 03.12.21.
//

import SwiftUI

struct NewChooseWeekView: View {
    //@StateObject var viewModel = NewNotificationsViewModel()
    @Binding var notificationDate: NotificationDate
    
    var body: some View {
        HStack {
            ForEach(1...7, id: \.self) { index in
                ZStack {
                    Circle()
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.2), radius: 6)
                    
                    Circle()
                        .fill(
                            notificationDate.weekdays.contains(where: { $0.id == index })
                            ? Color.accentColor : Color.clear)
                        .shadow(color: .black.opacity(0.2), radius: 6)
                        .overlay(
                            Text(weekdayNameFrom(weekdayNumber: index))
                                .minimumScaleFactor(0.6)
                                .lineLimit(1)
                                .font(.headline)
                                .padding(.horizontal, 2)
                        )
                }
                
                .onTapGesture {
                    if notificationDate.weekdays.contains(where: { $0.id == index }) {
                        notificationDate.weekdays.remove(WeekdayEnum(index: index))
                    } else {
                        notificationDate.weekdays.insert(WeekdayEnum(index: index))
                    }
                }
            }
        }
    }
}

struct NewChooseWeekView_Previews: PreviewProvider {
    static var previews: some View {
        NewChooseWeekView(notificationDate: .constant(.init(message: "Test", date: Date(), weekdays: [])))
            .environment(\.locale, .init(identifier: "de_DE"))
    }
}
