//
//  FirstWeekdayPickerView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 22.12.21.
//

import SwiftUI

struct FirstWeekdayPickerView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    
    var body: some View {
        List {
            ForEach(Calendar.FirstWeekdayEnum.allCases, id: \.self) { weekday in
                HStack {
                    Text(weekday.rawValue)
                    
                    Spacer()
                    
                    if weekday == settingsViewModel.firstWeekdaySelection {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    settingsViewModel.firstWeekdaySelection = weekday
                }
            }
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #endif
        .navigationTitle("First Day of the Week")
    }
}

struct FirstWeekdayPickerView_Previews: PreviewProvider {
    static var previews: some View {
        FirstWeekdayPickerView(settingsViewModel: SettingsViewModel())
    }
}
