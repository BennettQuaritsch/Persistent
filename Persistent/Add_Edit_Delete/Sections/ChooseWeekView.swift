//
//  ChooseWeekView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 27.08.21.
//

import SwiftUI

struct ChooseWeekView: View {
    
    var strings: [String] = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
    
    @Binding var selection: Int
    
    var body: some View {
        HStack {
            ForEach(strings, id: \.self) { string in
                Circle()
                    .foregroundColor(.accentColor)
                    .aspectRatio(contentMode: .fit)
                    .overlay(
                        Text(string)
                            .font(.headline)
                            .foregroundColor(.primary)
                    )
                    .onTapGesture {
                        selection = strings.firstIndex(of: string)!
                    }
                    .scaleEffect(selection == strings.firstIndex(of: string)! ? 1.1 : 1)
            }
        }
    }
}

struct ChooseWeekView_Previews: PreviewProvider {
    static var previews: some View {
        ChooseWeekView(selection: .constant(0))
    }
}
