//
//  ValueTypeSelectionView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 18.11.21.
//

import SwiftUI

struct ValueTypeSelectionView: View {
    @Binding var navigationPath: [AddEditViewNavigationEnum]
    @Binding var selection: HabitValueTypes
    @ObservedObject var viewModel: AddEditViewModel
    
    var body: some View {
        List {
            ValueTypeSelectionField(valueType: .number, selection: $selection, navigationPath: $navigationPath)
            
            Section("AddEditBase.ValueType.Section.Length") {
                ValueTypeSelectionField(valueType: .lengthKilometres, selection: $selection, navigationPath: $navigationPath)
                
                ValueTypeSelectionField(valueType: .lengthMetres, selection: $selection, navigationPath: $navigationPath)
                
                ValueTypeSelectionField(valueType: .lengthMiles, selection: $selection, navigationPath: $navigationPath)
                
                ValueTypeSelectionField(valueType: .lengthYards, selection: $selection, navigationPath: $navigationPath)
            }
            
            Section("AddEditBase.ValueType.Section.Volume") {
                ValueTypeSelectionField(valueType: .volumeLitres, selection: $selection, navigationPath: $navigationPath)
                
                ValueTypeSelectionField(valueType: .volumeMillilitres, selection: $selection, navigationPath: $navigationPath)
                
                ValueTypeSelectionField(valueType: .volumeQuarts, selection: $selection, navigationPath: $navigationPath)
                
                ValueTypeSelectionField(valueType: .volumeCups, selection: $selection, navigationPath: $navigationPath)
                
                ValueTypeSelectionField(valueType: .volumeOunces, selection: $selection, navigationPath: $navigationPath)
            }
            
            Section("AddEditBase.ValueType.Section.Time") {
                ValueTypeSelectionField(valueType: .timeHours, selection: $selection, navigationPath: $navigationPath)
                
                ValueTypeSelectionField(valueType: .timeMinutes, selection: $selection, navigationPath: $navigationPath)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("AddEditBase.ValueType.Header")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: selection) { _ in
            viewModel.objectWillChange.send()
        }
    }
    
    struct ValueTypeSelectionField: View {
        let valueType: HabitValueTypes
        @Binding var selection: HabitValueTypes
        @Binding var navigationPath: [AddEditViewNavigationEnum]
        
        var body: some View {
            HStack {
                Text(LocalizedStringKey(valueType.localizedNameString))
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
                
                navigationPath = []
            }
        }
    }
}

struct ValueTypeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ValueTypeSelectionView(navigationPath: .constant([]), selection: .constant(.number), viewModel: AddEditViewModel())
    }
}
