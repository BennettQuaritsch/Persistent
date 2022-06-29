//
//  ResertIntervalPickerView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 25.09.21.
//

import SwiftUI

struct ResertIntervalPickerView: View {
    @Binding var intervalChoice: ResetIntervals
    
    @Binding var valueString: String
    
    @Binding var timesPerDay: Int
    
    @Binding var valueTypeSelection: HabitValueTypes
    
    @FocusState var valueTypeTextFieldSelected: Bool
    
    var body: some View {
        Picker("Select a Interval", selection: $intervalChoice) {
            ForEach(ResetIntervals.allCases, id: \.self) { interval in
                Text(interval.name)
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
        TextField("Volume", text: $valueString, prompt: Text("How much?"))
            .keyboardType(.decimalPad)
            .focused($valueTypeTextFieldSelected)
    }
}

struct ResertIntervalPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ResertIntervalPickerView(intervalChoice: .constant(.daily), valueString: .constant(""), timesPerDay: .constant(3), valueTypeSelection: .constant(.number))
    }
}
