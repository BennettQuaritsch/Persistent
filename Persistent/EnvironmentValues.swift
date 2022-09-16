//
//  EnvironmentValues.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 17.03.22.
//

import Foundation
import SwiftUI
import CoreData

// Background context
fileprivate struct BackgroundContextEnvironmentKey: EnvironmentKey {
    static var defaultValue: NSManagedObjectContext = PersistenceController.shared.container.newBackgroundContext()
}

extension EnvironmentValues {
    var backgroundContext: NSManagedObjectContext {
        get { self[BackgroundContextEnvironmentKey.self] }
        set { self[BackgroundContextEnvironmentKey.self] = newValue }
    }
}


// ParentSizeClass
#if !os(watchOS)
fileprivate struct ParentSizeClassEnvironmentKey: EnvironmentKey {
    static var defaultValue: UserInterfaceSizeClass? = nil
}

extension EnvironmentValues {
    var parentSizeClass: UserInterfaceSizeClass? {
        get { self[ParentSizeClassEnvironmentKey.self] }
        set { self[ParentSizeClassEnvironmentKey.self] = newValue }
    }
}
#endif


// PurchaseInfo
fileprivate struct PurchaseInfoEnvironmentKey: EnvironmentKey {
    static var defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var purchaseInfo: Binding<Bool> {
        get { self[PurchaseInfoEnvironmentKey.self] }
        set { self[PurchaseInfoEnvironmentKey.self] = newValue }
    }
}

// Interface Color

fileprivate struct InterfaceColorEnvironmentKey: EnvironmentKey {
    static var defaultValue: Color = Color("Persistent")
}

extension EnvironmentValues {
    var interfaceColor: Color {
        get { self[InterfaceColorEnvironmentKey.self] }
        set { self[InterfaceColorEnvironmentKey.self] = newValue }
    }
}



fileprivate struct PersistenceControllerEnvironmentKey: EnvironmentKey {
    static var defaultValue: PersistenceController = PersistenceController.shared
}
extension EnvironmentValues {
    var persistenceController: PersistenceController {
        get { self[PersistenceControllerEnvironmentKey.self] }
        set { self[PersistenceControllerEnvironmentKey.self] = newValue }
    }
}

struct CloudSyncPreferenceKey: PreferenceKey {
    static var defaultValue: Bool = true
    
    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = nextValue()
    }
}
