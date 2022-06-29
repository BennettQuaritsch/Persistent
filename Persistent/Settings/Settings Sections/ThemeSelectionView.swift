//
//  ThemeSelectionView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 22.02.22.
//

import SwiftUI

struct ThemeSelectionView: View {
    @EnvironmentObject var userSettings: UserSettings
    
    var body: some View {
        List {
            Picker("Select a theme", selection: $userSettings.themeSelection) {
                ForEach(UserSettings.ThemeSelectionEnum.allCases, id: \.self) { theme in
                    Text(theme.shownName)
                        .tag(theme)
                }
            }
            .pickerStyle(.inline)
            .labelsHidden()
        }
    }
}

struct ThemeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ThemeSelectionView()
            .environmentObject(UserSettings())
    }
}
