//
//  HabitListUICollectionView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 19.09.21.
//

import SwiftUI
import UIKit

class HabitListViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct HabitListUICollectionView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct HabitListUICollectionView_Previews: PreviewProvider {
    static var previews: some View {
        HabitListUICollectionView()
    }
}
