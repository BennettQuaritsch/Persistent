//
//  SymbolColorView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 23.09.21.
//

import SwiftUI

struct SymbolColorView: View {
    @Binding var iconChoice: String
    
    @Binding var colorSelection: Int
    
    let rows = [
            GridItem(.fixed(50), spacing: 10),
            GridItem(.fixed(50))
        ]
    
    var body: some View {
        NavigationLink(destination: ChooseIconView(iconChoice: $iconChoice)) {
            ZStack(alignment: .leading) {
                Image(iconChoice)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .padding(.vertical, 5)
                    //.foregroundColor(iconColors[colorSelection])
                    .foregroundColor(iconColors[colorSelection])
            }
        }
        
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, alignment: .center, spacing: 10) {
                ForEach(0..<iconColors.count, id: \.self) { index in
                    ZStack {
                        Circle()
                            .scaledToFit()
                            .foregroundColor(iconColors[index])
                            .shadow(color: Color.black.opacity(0.4) ,radius: colorSelection == index ? 4 : 0)
                    }
                    .scaleEffect(colorSelection == index ? 1.1 : 1)
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
                            colorSelection = index
                        }
                    }
                }
            }
            .padding()
        }
        .listRowInsets(EdgeInsets())
    }
}

struct SymbolColorView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolColorView(iconChoice: .constant("Walking"), colorSelection: .constant(0))
            
    }
}
