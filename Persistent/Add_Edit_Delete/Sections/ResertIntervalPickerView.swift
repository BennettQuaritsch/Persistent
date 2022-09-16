//
//  ResertIntervalPickerView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 25.09.21.
//

import SwiftUI

struct ResertIntervalPickerView: View {
    let breakHabitEnum: BuildOrBreakHabitEnum
    
    @Binding var intervalChoice: ResetIntervals
    
    @Binding var valueString: String
    
    @Binding var timesPerDay: Int
    
    @Binding var valueTypeSelection: HabitValueTypes
    
    @FocusState var valueTypeTextFieldSelected: AlternativeEditHabitBaseView.TextFieldFocusEnum?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Picker("AddEditBase.Interval.Name", selection: $intervalChoice) {
                ForEach(ResetIntervals.allCases, id: \.self) { interval in
                    Text(interval.localizedStringKey)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            
    //        switch valueTypeSelection {
    //        case .number:
    //            Stepper(String(timesPerDay), value: $timesPerDay, in: 1...1000000)
    //        default:
    //            TextField("Volume", text: $valueString, prompt: Text("How much?"))
    //                .keyboardType(.decimalPad)
    //                .focused($valueTypeTextFieldSelected)
    //        }
            HStack {
                Text(breakHabitEnum == .breakHabit ? "AddEditBase.Goal.Header.Break" : "AddEditBase.Goal.Header.Build")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
                
                TextField("AddEditBase.Goal.Name", text: $valueString, prompt: Text("AddEditBase.Goal.Prompt"))
                    .keyboardType(.decimalPad)
                    .focused($valueTypeTextFieldSelected, equals: .standardAdd)
            }
        }
        
    }
}

struct ResertIntervalPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ResertIntervalPickerView(breakHabitEnum: .buildHabit, intervalChoice: .constant(.daily), valueString: .constant(""), timesPerDay: .constant(3), valueTypeSelection: .constant(.number))
    }
}
