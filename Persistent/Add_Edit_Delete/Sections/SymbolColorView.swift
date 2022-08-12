//
//  SymbolColorView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 23.09.21.
//

import SwiftUI

struct SymbolColorView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.colorSchemeContrast) var colorSchemeContrast
    
    @Binding var iconChoice: String
    
    @Binding var colorSelection: Int
    @Binding var colorSelectionName: String
    
    let rows = [
            GridItem(.fixed(50), spacing: 10),
            GridItem(.fixed(50))
        ]
    
    var backgroundColor: Color {
        if colorScheme == .dark {
            return .secondarySystemGroupedBackground
        } else {
            return .systemBackground
        }
    }
    
    var body: some View {
        NavigationLink(destination: ChooseIconView(iconChoice: $iconChoice)) {
            ZStack(alignment: .leading) {
                Image(iconChoice)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 50)
                    .padding(.vertical, 5)
                    //.foregroundColor(iconColors[colorSelection])
                    .foregroundColor(Color.iconColors.first(where: { $0.name == colorSelectionName })?.color ?? Color("Primary"))
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .background(backgroundColor, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
            }
        }
        
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, alignment: .center, spacing: 10) {
                ForEach(Color.iconColors, id: \.self) { iconColor in
                    ZStack {
                        Circle()
                            .scaledToFit()
                            .foregroundColor(iconColor.color)
//                            .shadow(color: Color.black.opacity(0.6), radius: iconColor.name == colorSelectionName ? 3 : 0)
                            .overlay(
                                Group {
                                    ZStack {
                                        if iconColor.name == colorSelectionName && colorSchemeContrast == .increased {
                                            Circle()
                                                .stroke(Color.primary, lineWidth: 5)
                                        }
                                        
                                        if iconColor.name != colorSelectionName {
                                            Circle()
                                                .fill(Color.systemBackground)
                                                .padding(10)
                                                .transition(.scale.animation(.easeOut(duration: 0.1)))
                                        }
                                    }
                                }
                            )
                    }
                    .scaleEffect(iconColor.name == colorSelectionName ? 1.1 : 1)
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.2)) {
//                            colorSelection = index
                            colorSelectionName = iconColor.name
                            
                        }
                    }
                }
            }
            .padding()
            .drawingGroup()
        }
        .listRowInsets(EdgeInsets())
        .frame(maxWidth: .infinity)
        .background(backgroundColor, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}

struct SymbolColorView_Previews: PreviewProvider {
    static var previews: some View {
        SymbolColorView(iconChoice: .constant("Walking"), colorSelection: .constant(0), colorSelectionName: .constant("Yellow"))
            
    }
}
