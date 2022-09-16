//
//  AddEditNotificationBaseView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 06.09.22.
//

import SwiftUI

struct AddEditNotificationView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.interfaceColor) var interfaceColor
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var notificationsViewModel: NotificationsViewModel
    
    /// Initializer fürs Hinzufügen von Notifications
    init(notificationsViewModel: NotificationsViewModel) {
        self.notificationsViewModel = notificationsViewModel
        
        let notificationDate = NotificationDate(message: "", date: Date(), weekdays: [])
        self._notificationDate = State(initialValue: notificationDate)
        
        self.navigationTitle = "AddEditBase.Notifications.AddNotification"
        self.isEditingView = false
    }
    
    /// Initializer fürs Bearbeiten von Notifications
    init(notificationsViewModel: NotificationsViewModel, notificationDate: NotificationDate) {
        self.notificationsViewModel = notificationsViewModel
        
        let notificationDate = notificationDate
        self._notificationDate = State(initialValue: notificationDate)
        
        self.navigationTitle = "AddEditBase.Notifications.EditNotification"
        self.isEditingView = true
    }
    
    let navigationTitle: LocalizedStringKey
    let isEditingView: Bool
    
    @State private var notificationDate: NotificationDate
    
    @State private var datePickerShown: Bool = false
    @FocusState private var textFieldFocused: Bool
    
    var backgroundColor: Color {
        if colorScheme == .dark {
            return .secondarySystemGroupedBackground
        } else {
            return .systemBackground
        }
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack(alignment: .bottom) {
                    ZStack(alignment: .init(horizontal: .center, vertical: .zStackVerticalCenter)) {
                        VStack(alignment: .leading, spacing: 25) {
                            TextField("AddEditBase.Notifications.Message.Name", text: $notificationDate.message, prompt: Text("AddEditBase.Notifications.Message.Prompt"), axis: .vertical)
                                .textFieldStyle(.continuousRounded(backgroundColor))
                                .lineLimit(1 ... 5)
                                .focused($textFieldFocused)
                            
                            VStack(spacing: 10) {
                                Text("AddEditBase.Notifications.DatePicker")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                
                                Button {
                                    withAnimation {
                                        textFieldFocused = false
                                        datePickerShown = true
                                    }
                                } label: {
                                    Text(notificationDate.date.formatted(.dateTime.hour().minute()))
                                        .font(.headline)
                                        .padding(15)
                                        .foregroundColor(.systemBackground)
                                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                              
                                }
                                .alignmentGuide(VerticalAlignment.zStackVerticalCenter) { d in
                                    return d[VerticalAlignment.center]
                                }
                                .accessibilityRepresentation {
                                    DatePicker("AddEditBase.Notifications.DatePicker", selection: $notificationDate.date, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            
                            
                            VStack(spacing: 10) {
                                Text("AddEditBase.Notifications.WeekdaySelection.Header")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                
                                ChooseWeekView(notificationDate: $notificationDate, tappable: true)
                                    .ignoresSafeArea(.keyboard)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if datePickerShown {
                                withAnimation {
                                    datePickerShown = false
                                }
                            }
                        }
                        .zIndex(1)
                        .ignoresSafeArea(.keyboard)
                        
                        if datePickerShown {
                            VStack(spacing: 0) {
                                Button {
                                    withAnimation {
                                        datePickerShown = false
                                    }
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.headline)
                                        .imageScale(.large)
                                        .padding(7)
                                        .background(Color.black.opacity(0.1), in: Circle())
                                }
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .accessibilityLabel("General.Buttons.Close")
                                
                                DatePicker("AddEditBase.Notifications.DatePicker", selection: $notificationDate.date, displayedComponents: .hourAndMinute)
                                    .datePickerStyle(.wheel)
                                    .labelsHidden()
                            }
                            .padding()
                            .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                            .transition(.popUpScaleTransition)
                            .alignmentGuide(VerticalAlignment.zStackVerticalCenter) { d in
    //                            return test
                                return d[VerticalAlignment.bottom]
                            }
//                            .padding(.horizontal, 20)
                            .frame(width: geo.size.width * 0.8)
                            .zIndex(2)
                                
                        }
                    }
                    .navigationTitle(navigationTitle)
                    .background(Color.systemGray6, ignoresSafeAreaEdges: .all)
        //            .ignoresSafeArea(.keyboard)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button(role: .cancel) {
                                dismiss()
                            } label: {
                                Text("General.Buttons.Close")
                            }
                        }
                        
                        if isEditingView {
                            ToolbarItem(placement: .destructiveAction) {
                                Button(role: .destructive) { notificationsViewModel.notifcationArray.removeAll(where: { $0.id == notificationDate.id })
                                    
                                    dismiss()
                                } label: {
                                    Label("AddEditBase.Notifications.DeleteNotification", systemImage: "trash")
                                }
                            }
                        }
                    }
                    .onAppear {
                        notificationDate.weekdays = [getDateIndex()]
                    }
                    
                    VStack(alignment: .trailing) {
                        if textFieldFocused {
                            Button {
                                textFieldFocused = false
                            } label: {
                                Image(systemName: "keyboard.chevron.compact.down")
                                    .imageScale(.large)
                                    .fontWeight(.semibold)
                                    .padding()
                                    .background(colorScheme == .dark ? Color.systemGray5 : Color.systemBackground, in: Capsule())
                            }
                            .accessibilityLabel("Dismiss Keyboard")
                            .padding(.trailing)
                            .transition(.opacity.animation(.easeInOut(duration: 0.07)))
                            .zIndex(2)
                        }
                        
                        Button {
                            if let arrayItemIndex = notificationsViewModel.notifcationArray.firstIndex(where: { $0.id == notificationDate.id }) {
                                notificationsViewModel.notifcationArray.remove(at: arrayItemIndex)
                                
                                notificationsViewModel.notifcationArray.insert(notificationDate, at: arrayItemIndex)
                            } else {
                                notificationsViewModel.notifcationArray.append(notificationDate)
                            }
                            dismiss()
                        } label: {
                            Text("AddEditBase.Notifications.SaveNotification")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(15)
                                .foregroundColor(.systemBackground)
                                .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                                .padding(.horizontal)
                                .padding(.bottom)
                        }
                    }
                }
            }
        }
    }
}

extension AddEditNotificationView {
    func getDateIndex() -> Int {
        let cal = Calendar.defaultCalendar
        var weekday = (cal.component(.weekday, from: Date()) - 1) - (cal.firstWeekday - 1)
        
        while weekday < 0 {
            weekday += 7
        }
        
        return weekday + 1
    }
}

extension VerticalAlignment {
    struct ZStackVerticalCenter: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            d[VerticalAlignment.center]
        }
    }

    static let zStackVerticalCenter = VerticalAlignment(ZStackVerticalCenter.self)
}

struct AddEditNotificationBaseView_Previews: PreviewProvider {
    static var previews: some View {
        AddEditNotificationView(notificationsViewModel: NotificationsViewModel(), notificationDate: NotificationDate(message: "", date: Date(), weekdays: []))
            .frame(maxHeight: .infinity)
            .background(Color.systemGray6, ignoresSafeAreaEdges: .all)
    }
}
