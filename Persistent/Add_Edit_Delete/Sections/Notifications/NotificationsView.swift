//
//  NewNotificationsView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 02.12.21.
//

import SwiftUI

struct NotificationsView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.interfaceColor) var interfaceColor
    
    @ObservedObject var viewModel: NotificationsViewModel
    
    @State private var addNotificationSheet: Bool = false
    @State private var editSheetNotificationDate: NotificationDate? = nil
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach($viewModel.notifcationArray) { $notificationDate in
                    VStack {
                        HStack {
                            Text(notificationDate.message)
                                .font(.system(.body, design: .rounded, weight: .regular))
                                .lineLimit(3)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer(minLength: 15)
                            
                            Text(notificationDate.date.formatted(.dateTime.hour().minute()))
                                .font(.system(.headline, design: .rounded, weight: .semibold))
                        }
                        .padding(EdgeInsets(top: 5, leading: 3, bottom: 0, trailing: 3))
                        
                        ChooseWeekView(notificationDate: $notificationDate, tappable: false, inactiveButtonColor: colorScheme == .dark ? Color.systemGray4 : Color.systemGray6)
                            .frame(height: 45)
                    }
                    .transition(.popUpScaleTransition)
                    .padding(10)
                    .background(colorScheme == .dark ? Color.systemGray5 : Color.systemBackground, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .contentShape(.contextMenuPreview, RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .contextMenu {
                        NotificationsContextMenuButtons(
                            viewModel: viewModel,
                            notificationDate: $notificationDate,
                            editSheetNotificationDate: $editSheetNotificationDate
                        )
                    }
                    .contentShape(Rectangle())
//                    .onTapGesture {
//                        editSheetNotificationDate = notificationDate
//                    }
                    .highPriorityGesture(
                        TapGesture()
                            .onEnded { _ in
                                editSheetNotificationDate = notificationDate
                            }
                        
                    )
                    .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color.systemGroupedBackground, ignoresSafeAreaEdges: .all)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    addNotificationSheet = true
                } label: {
                    Label("AddEditBase.Notifications.AddNotification", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $addNotificationSheet) {
            AddEditNotificationView(notificationsViewModel: viewModel)
                .accentColor(interfaceColor)
        }
        .sheet(item: $editSheetNotificationDate) { notificationDate in
            AddEditNotificationView(notificationsViewModel: viewModel, notificationDate: notificationDate)
                .accentColor(interfaceColor)
        }
        .navigationTitle("AddEditBase.Notifications.Header")
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

extension NotificationsView {
    struct NotificationsContextMenuButtons: View {
        @ObservedObject var viewModel: NotificationsViewModel
        @Binding var notificationDate: NotificationDate
        @Binding var editSheetNotificationDate: NotificationDate?
        
        var body: some View {
            Button(role: .destructive) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation {
                        viewModel.notifcationArray.removeAll(where: { $0.id == notificationDate.id })
                    }
                }
            } label: {
                Label("AddEditBase.Notifications.DeleteNotification", systemImage: "trash")
                    .labelStyle(.iconOnly)
            }
            
            Button() {
                editSheetNotificationDate = notificationDate
            } label: {
                Label("AddEditBase.Notifications.EditNotification", systemImage: "pencil")
                    .labelStyle(.iconOnly)
            }
        }
    }
}

struct NewNotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            NotificationsView(viewModel: NotificationsViewModel())
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }

    }
}
