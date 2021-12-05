//
//  ValueTypeSelectionView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 18.11.21.
//

import SwiftUI

struct ValueTypeSelectionView: View {
    @Binding var selection: HabitValueTypes
    
    var body: some View {
        Picker(selection: $selection) {
            ForEach(HabitValueTypes.allCases, id: \.self) { value in
                Text(value.name)
            }
        } label: {
            Text("Select the type of value")
        }
    }
}

struct ValueTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ValueTypeSelectionView(selection: .constant(.number))
    }
}
