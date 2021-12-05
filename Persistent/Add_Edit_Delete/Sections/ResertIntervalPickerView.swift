//
//  ResertIntervalPickerView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 25.09.21.
//

import SwiftUI

struct ResertIntervalPickerView: View {
    @Binding var intervalChoice: String
    
    let durationChoice: [String] = ["Day", "Week", "Month"]
    
    @Binding var valueString: String
    
    @Binding var timesPerDay: Int32
    
    @Binding var valueTypeSelection: HabitValueTypes
    
    @FocusState var valueTypeTextFieldSelected: Bool
    
    var body: some View {
        Picker("Tag oder Woche?", selection: $intervalChoice) {
            ForEach(durationChoice, id: \.self) { choice in
                Text(choice)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        
        switch valueTypeSelection {
        case .number:
            Stepper(String(timesPerDay), value: $timesPerDay, in: 1...50)
        case .time:
            Text("")
        case .volume:
            TextField("Volume", text: $valueString, prompt: Text("How much?"))
                .keyboardType(.numberPad)
                .focused($valueTypeTextFieldSelected)
        }
    }
}

struct ResertIntervalPickerView_Previews: PreviewProvider {
    static var previews: some View {
        ResertIntervalPickerView(intervalChoice: .constant("Daily"), valueString: .constant(""), timesPerDay: .constant(3), valueTypeSelection: .constant(.number))
    }
}
