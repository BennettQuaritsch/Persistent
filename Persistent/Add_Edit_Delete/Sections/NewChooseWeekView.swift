//
//  NewChooseWeekView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 03.12.21.
//

import SwiftUI

struct NewChooseWeekView: View {
    @Environment(\.colorScheme) var colorScheme
    
    //@StateObject var viewModel = NewNotificationsViewModel()
    @Binding var notificationDate: NotificationDate
    
    var body: some View {
        HStack {
            ForEach(1...7, id: \.self) { index in
                ZStack {
                    Circle()
                        .fill(.thickMaterial)
                        .shadow(color: colorScheme == .dark ? .white.opacity(0.2) : .black.opacity(0.25), radius: 5)
                    
                    Circle()
                        .fill(
                            notificationDate.weekdays.contains(where: { $0 == index })
                            ? Color.accentColor : Color.clear)
                        //.shadow(color: colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.25), radius: 5)
                        .overlay(
                            Text(weekdayNameFrom(weekdayNumber: index))
                                .minimumScaleFactor(0.6)
                                .lineLimit(1)
                                .font(.headline)
                                .padding(.horizontal, 2)
                        )
                }
                
                .onTapGesture {
                    if notificationDate.weekdays.contains(where: { $0 == index }) {
                        notificationDate.weekdays
                            .remove(index)
                            //.remove(WeekdayEnum(index: index))
                    } else {
                        notificationDate.weekdays
                            .insert(index)
                            //.insert(WeekdayEnum(index: index))
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
