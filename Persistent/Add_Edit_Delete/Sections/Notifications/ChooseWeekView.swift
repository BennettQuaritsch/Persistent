//
//  NewChooseWeekView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 03.12.21.
//

import SwiftUI

struct ChooseWeekView: View {
    @Environment(\.colorScheme) var colorScheme
    
    //@StateObject var viewModel = NewNotificationsViewModel()
    @Binding var notificationDate: NotificationDate
    
    let tappable: Bool
    let inactiveButtonColor: Color
    
    init(
        notificationDate: Binding<NotificationDate>,
        tappable: Bool,
        inactiveButtonColor: Color = .systemGray5
    ) {
        self._notificationDate = notificationDate
        self.tappable = tappable
        self.inactiveButtonColor = inactiveButtonColor
    }
    
    var body: some View {
        HStack {
            ForEach(1...7, id: \.self) { index in
                ZStack {
                    Circle()
                        .fill(inactiveButtonColor)
                    
                    Circle()
                        .fill(
                            notificationDate.weekdays.contains(where: { $0 == index })
                            ? Color.accentColor : Color.clear)
                        //.shadow(color: colorScheme == .dark ? .white.opacity(0.20) : .black.opacity(0.25), radius: 5)
                        .overlay(
                            Text(weekdayNameFrom(weekdayNumber: index))
                                .foregroundColor(notificationDate.weekdays.contains(where: { $0 == index }) ? Color.systemBackground : Color.secondary)
                                .minimumScaleFactor(0.6)
                                .lineLimit(1)
                                .font(.headline)
                                .padding(.horizontal, 2)
                        )
                }
                .frame(maxHeight: 50)
                .onTapGesture {
                    if tappable {
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
}

struct NewChooseWeekView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseWeekView(notificationDate: .constant(.init(message: "Test", date: Date(), weekdays: [])), tappable: true)
            .environment(\.locale, .init(identifier: "de_DE"))
    }
}
