//
//  ValueTypeSelectionView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 18.11.21.
//

import SwiftUI

struct ValueTypeSelectionView: View {
    @Binding var viewActive: Bool
    @Binding var selection: HabitValueTypes
    
    var body: some View {
        List {
            ValueTypeSelectionField(valueType: .number, selection: $selection, viewActive: $viewActive)
            
            Section("Length") {
                ValueTypeSelectionField(valueType: .lengthKilometres, selection: $selection, viewActive: $viewActive)
                
                ValueTypeSelectionField(valueType: .lengthMetres, selection: $selection, viewActive: $viewActive)
                
                ValueTypeSelectionField(valueType: .lengthMiles, selection: $selection, viewActive: $viewActive)
                
                ValueTypeSelectionField(valueType: .lengthYards, selection: $selection, viewActive: $viewActive)
            }
            
            Section("Volume") {
                ValueTypeSelectionField(valueType: .volumeLitres, selection: $selection, viewActive: $viewActive)
                
                ValueTypeSelectionField(valueType: .volumeMillilitres, selection: $selection, viewActive: $viewActive)
                
                ValueTypeSelectionField(valueType: .volumeQuarts, selection: $selection, viewActive: $viewActive)
                
                ValueTypeSelectionField(valueType: .volumeCups, selection: $selection, viewActive: $viewActive)
                
                ValueTypeSelectionField(valueType: .volumeOunces, selection: $selection, viewActive: $viewActive)
            }
            
            Section("Time") {
                ValueTypeSelectionField(valueType: .timeHours, selection: $selection, viewActive: $viewActive)
                
                ValueTypeSelectionField(valueType: .timeMinutes, selection: $selection, viewActive: $viewActive)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Value Type")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    struct ValueTypeSelectionField: View {
        let valueType: HabitValueTypes
        @Binding var selection: HabitValueTypes
        @Binding var viewActive: Bool
        
        var body: some View {
            HStack {
                Text(valueType.localizedNameString)
                    .tag(valueType)
                
                Spacer()
                
                if valueType == selection {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                selection = valueType
                
                viewActive = false
            }
        }
    }
}

struct ValueTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ValueTypeSelectionView(viewActive: .constant(true), selection: .constant(.number))
    }
}
