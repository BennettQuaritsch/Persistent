//
//  iPhoneView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 13.06.21.
//

import SwiftUI

struct iPhoneView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var userSettings: UserSettings
    
//    @FetchRequest(entity: HabitTag.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \HabitTag.name, ascending: true)]) var tags: FetchedResults<HabitTag>
    
    @EnvironmentObject var settings: UserSettings
    
    var body: some View {
        NavigationView {
            ListView()
        }
    }
}



struct iPhoneView_Previews: PreviewProvider {
    static var previews: some View {
        iPhoneView()
            //.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
