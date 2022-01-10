//
//  NotificationsView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 25.09.21.
//

import SwiftUI

struct NotificationsView: View {
//    init(notificationEnabled: Binding<Bool>, notificationAmount: Int) {
//        self._viewModel = StateObject(wrappedValue: NotificationsViewModel(
//            notificationEnabled: notificationEnabled,
//            notificationAmount: notificationAmount
//        ))
//    }
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var viewModel: NotificationsViewModel
    
    var body: some View {
        VStack {
            Toggle("Enable Notification", isOn: $viewModel.notificationEnabled)
            
            if viewModel.notificationEnabled {
                Divider()
                
                Stepper("How many Notifications?", onIncrement: {
                    self.viewModel.notificationDates.append(Date())
                    self.viewModel.notificationAmount += 1
                    
                    // Multiple weekdaySelections
                    let calendar: Calendar = Calendar.defaultCalendar
                    let component = calendar.component(.weekday, from: Date())
                    viewModel.weekdaySelection.append(component - calendar.firstWeekday)
                }, onDecrement: {
                    self.viewModel.notificationAmount -= 1
                    
                    if viewModel.notificationAmount < 1 {
                        self.viewModel.notificationAmount += 1
                        
                        return
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        self.viewModel.notificationDates.removeLast()
                        self.viewModel.weekdaySelection.removeLast()
                    }
                })
                
                Divider()
                
                ForEach(1...viewModel.notificationAmount, id: \.self) { index in
                    DatePicker("Nr. \(index)", selection: $viewModel.notificationDates[index - 1], displayedComponents: [.hourAndMinute])
                        .onChange(of: viewModel.notificationDates) { _ in
                            print(viewModel.notificationDates)
                        }
                    
                    ChooseWeekView(selection: $viewModel.weekdaySelection[index - 1])
                        .onChange(of: viewModel.weekdaySelection, perform: { array in
                            let calendar: Calendar = Calendar.defaultCalendar
                            
                            let component = calendar.component(.weekday, from: viewModel.notificationDates[index - 1])
                            
                            
                            // Dem Wochentag muss der für iOS erste Wochentag abgezogen werden, sonst verschiebt sich die Selection
                            let toAdd = array[index - 1] - (component - calendar.firstWeekday)
                            
                            viewModel.notificationDates[index - 1] = calendar.date(byAdding: .weekday, value: toAdd, to: viewModel.notificationDates[index - 1]) ?? viewModel.notificationDates[index - 1]
                        })
                        .onAppear {
                            let calendar: Calendar = Calendar.defaultCalendar
                            let component = calendar.component(.weekday, from: Date())
                            viewModel.weekdaySelection[index - 1] = component - calendar.firstWeekday
                            print("on appear \(component)")
                        }
                }
            }
        }
    }
    
    
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationsView(viewModel: NotificationsViewModel())
    }
}
