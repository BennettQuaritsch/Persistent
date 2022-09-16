//
//  ComparableHabitTypesPicker.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 18.04.22.
//

import SwiftUI

struct ComparableHabitTypesPicker: View {
    @ObservedObject var habit: HabitItem
    
    @Binding var selection: HabitValueTypes
    
    var body: some View {
        if habit.valueTypeEnum == .number {
            EmptyView()
        } else {
            Picker("DetailView.AddRemoveMultiple.ComparableTypesPicker.Header", selection: $selection) {
                ForEach(habit.valueTypeEnum.comparableTypes, id: \.self) { habitType in
                    Text(LocalizedStringKey(habitType.localizedNameString))
                        .tag(habitType)
                }
            }
            .pickerStyle(.segmented)
//            .onAppear {
//                selection = habit.valueTypeEnum
//            }
        }
    }
}

struct ComparableHabitTypesPicker_Previews: PreviewProvider {
    static var previews: some View {
        ComparableHabitTypesPicker(habit: HabitItem.testHabit, selection: .constant(HabitValueTypes.number))
    }
}
