//
//  iPhoneView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 13.06.21.
//

import SwiftUI

struct iPhoneView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var appViewModel: AppViewModel
    
    @EnvironmentObject var settings: UserSettings
    
    @State private var habitToEdit: HabitItem? = nil
    @State private var navigationPath: [HabitItem] = []
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ListView(navigationPath: $navigationPath, habitToEdit: $habitToEdit)
                .navigationDestination(for: HabitItem.self) { habit in
                    HabitDetailView(habit: habit, habitToEdit: $habitToEdit)
                        .environmentObject(appViewModel)
                }
        }
//        .onChange(of: scenePhase) { scene in
//            if scene == .background {
//                navigationModel.save()
//            }
//        }
    }
}



struct iPhoneView_Previews: PreviewProvider {
    static var previews: some View {
        iPhoneView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environment(\.purchaseInfo, .constant(true))
            .environmentObject(UserSettings())
            .environmentObject(AppViewModel())
    }
}
