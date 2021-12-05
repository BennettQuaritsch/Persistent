//
//  ChangeAppIconView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 12.11.21.
//

import SwiftUI

struct ChangeAppIconView: View {
    let viewModel = ChangeAppIconViewModel()
    
    var body: some View {
        List(ChangeAppIconViewModel.CustomAppIcons.allCases, id: \.self) { icon in
            Button {
                Task {
                    await viewModel.setAppIcon(icon.fileName)
                }
            } label: {
                HStack {
                    icon.image
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .padding(.trailing, 5)
                    
                    Text(icon.iconName)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
}

struct ChangeAppIconView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeAppIconView()
    }
}
