//
//  testview.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 24.08.22.
//

import SwiftUI

struct testview: View {
    @State private var test = ""
    var body: some View {
        VStack {
            TextField("Hey", text: $test)
            
            Spacer()
        }
    }
}

struct testview_Previews: PreviewProvider {
    static var previews: some View {
        testview()
    }
}
