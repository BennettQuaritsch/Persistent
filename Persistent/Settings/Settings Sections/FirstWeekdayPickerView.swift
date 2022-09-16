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
                    Text(weekday.localizedStringKey)
                    
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
        .navigationTitle("Settings.Calendar.FirstDay")
    }
}

struct FirstWeekdayPickerView_Previews: PreviewProvider {
    static var previews: some View {
        FirstWeekdayPickerView(settingsViewModel: SettingsViewModel())
    }
}
