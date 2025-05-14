//
//  SettingsView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 24.05.21.
//

import SwiftUI
import WidgetKit
import StoreKit
//import CloudKitSyncMonitor

struct SettingsView: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var storeManager: StoreManager
    
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.purchaseInfo) var purchaseInfo
    @Environment(\.dismiss) var dismiss
    
    @State var premiumSheet: Bool = false
    @State private var premiumNavigationActive: Bool = false
    
    @StateObject private var viewModel: SettingsViewModel = .init()
    
//    @ObservedObject private var syncMonitor = SyncMonitor.shared
    
//    var syncStateText: String {
//        switch syncMonitor.syncStateSummary {
//        case .notStarted:
//            return "Sync not started"
//        case .inProgress:
//            return "Sync is in progress"
//        case .succeeded:
//            let importState = syncMonitor.importState
//            let exportState = syncMonitor.exportState
//            
//            if case let .succeeded(_, ended: importDate) = importState, case let .succeeded(_, ended: exportDate) = exportState {
//                let date = max(importDate, exportDate)
//                
//                return "iCloud Sync was successful at \(date.formatted(.dateTime.hour().minute()))"
//            } else if case let .succeeded(_, ended: importDate) = importState {
//                return "iCloud Sync was successful at \(importDate.formatted(.dateTime.hour().minute()))"
//            } else if case let .succeeded(_, ended: exportDate) = exportState {
//                return "iCloud Sync was successful at \(exportDate.formatted(.dateTime.hour().minute()))"
//            }
//            
//            return "Sync succeeded"
//        case .noNetwork:
//            return "No network available"
//        case .accountNotAvailable:
//            return "No iCloud Account available"
//        case .notSyncing:
//            return "Not syncing"
//        default:
//            return "An error occured"
//        }
//    }
    
    var product: Product? {
        return storeManager.products.first(where: { $0.id == "quaritsch.bennnett.Persistent.premium.single" })
    }
    
    enum BuyPremiumNavigationEnum: Hashable {
        case buyPremiumNavigation
    }
    
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                ZStack {
                    Button {
                        navigationPath.append(BuyPremiumNavigationEnum.buyPremiumNavigation)
                    } label: {
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 10) {
                                Text("Settings.PersistentPremium.Header")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.accentColor)
                                
                                if purchaseInfo.wrappedValue {
                                    Text("Settings.PersistentPremium.BoughtText")
                                        .fontWeight(.semibold)
                                } else {
                                    Text("Settings.PersistentPremium.BuyNowText \(product?.displayPrice ?? NSLocalizedString("Settings.PersistentPremium.BuyNowText.unknowPrice", comment: ""))")
                                        .fontWeight(.semibold)
                                        .multilineTextAlignment(.center)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(10)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                
                Section("Settings.InterfaceDesign.Header") {
                    NavigationLink(destination: AccentColorSetting()) {
                        HStack {
                            Image(systemName: "paintbrush")
                                .foregroundColor(userSettings.accentColor)
                            
                            Text("Settings.InterfaceDesign.AccentTheme")
                        }
                    }
                    
                    Picker(selection: $userSettings.simplerListCellColor) {
                        Text("Settings.InterfaceDesign.ListCellColor.Colorful").tag(false)
                            .accessibilityIdentifier("ColorfulOption")
                        Text("Settings.InterfaceDesign.ListCellColor.Muted").tag(true)
                            .accessibilityIdentifier("MutedOption")
                    } label: {
                        HStack {
                            Image(systemName: "paintpalette")
                                .foregroundColor(userSettings.accentColor)
                            
                            Text("Settings.InterfaceDesign.ListCellColor")
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("ListCellColorPicker")
                    
                    NavigationLink(destination: ChangeAppIconView()) {
                        HStack {
                            Image(systemName: "app")
                                .foregroundColor(userSettings.accentColor)
                            
                            Text("Settings.InterfaceDesign.AppIcon")
                        }
                    }
                    
                    Picker(selection: $userSettings.leftHandedInterface) {
                        Text("Settings.InterfaceDesign.HandPreference.Left").tag(true)
                        Text("Settings.InterfaceDesign.HandPreference.Right").tag(false)
                    } label: {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(userSettings.accentColor)
                            
                            Text("Settings.InterfaceDesign.HandPreference")
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                Section("Settings.Habits") {
                    NavigationLink(destination: NightOwlModeView()) {
                        HStack {
                            Image(systemName: "moon.stars")
                                .foregroundColor(userSettings.accentColor)
                            
                            Text("Settings.Habits.NightOwl")
                        }
                    }
                    
                    NavigationLink(destination: ArchivedListView()) {
                        HStack {
                            Image(systemName: "archivebox")
                                .foregroundColor(userSettings.accentColor)
                            
                            Text("Settings.Habits.Archived")
                        }
                    }
                }
                
                Section("Settings.Calendar") {
                    NavigationLink(destination: FirstWeekdayPickerView(settingsViewModel: viewModel)) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(userSettings.accentColor)
                            
                            Text("Settings.Calendar.FirstDay")
                        }
                    }
                }
                
//                Section("Settings.Sync.Header") {
//                    HStack {
//                        Image(systemName: syncMonitor.syncStateSummary.symbolName)
//                            .foregroundColor(userSettings.accentColor)
//                        
//                        VStack(alignment: .leading, spacing: 3) {
//                            Text("Settings.Sync.Body")
//                            
//                            Text(syncStateText)
//                                .font(.footnote)
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                    .padding(.vertical, 1)
//                }
                
                Section("Settings.About.Header") {
                    NavigationLink(destination: AboutAppView()) {
                        Label("Settings.About.About", systemImage: "info.circle.fill")
                    }
                    
                    NavigationLink(destination: AboutPersistentView()) {
                        Label("Settings.About.Thanks", systemImage: "hand.thumbsup.fill")
                    }
                }
                
                //NavigationLink("calendar", destination: CalendarPageViewController(toggle: .constant(true), habitDate: .constant(Date()), date: Date(), habit: previewTestHabit))
                
//                NavigationLink(destination: AlternativeListView()) {
//                    Text("Alternativer List View")
//                }
//
//
//                Button("Update Widgets") {
//                    WidgetCenter.shared.reloadAllTimelines()
//                }
//
//                #if os(iOS)
//                Button("Delete all notifications") {
//                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
//                }
//                #endif
                
//                NavigationLink(destination: HabitCompletionGraph()) {
//                    Text("Graph")
//                }
//
//                NavigationLink("Tags", destination: AlternativeTagSection(selectedTags: .constant(Set<UUID>())))
            }
            .symbolVariant(.fill)
            #if os(iOS)
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Settings.Navigation")
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("Settings.Toolbar.Close")
                    }
                    .accessibilityIdentifier("SettingsCloseButton")
                }
            }
            .navigationDestination(for: BuyPremiumNavigationEnum.self) { _ in
                BuyPremiumView()
            }
        }
        .sheet(isPresented: $premiumSheet) {
            #if os(iOS)
            NavigationView {
                BuyPremiumView()
                    .accentColor(userSettings.accentColor)
                    .environment(\.horizontalSizeClass, horizontalSizeClass)
            }
            #endif
        }
    }
}

prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
        get: { !value.wrappedValue },
        set: { value.wrappedValue = !$0 }
    )
}


struct AccentColorSetting: View {
    @EnvironmentObject private var settings: UserSettings
    @State var selection = "Persistent"
    
    var body: some View {
        List {
            Picker("Settings.InterfaceDesign.AccentTheme.ColorPicker", selection: $selection) {
                ForEach(settings.accentColorNames, id: \.self) { name in
                    HStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(name))
                            .scaledToFit()
                            .frame(width: 30)
                            .padding(.trailing, 5)

                        Text(name)
                    }
                }
            }
            .labelsHidden()
            .pickerStyle(InlinePickerStyle())
            .onChange(of: selection, perform: { value in
//                settings.accentColorIndex = value
                settings.accentColorName = value
            })
            
            Picker("Settings.InterfaceDesign.AccentTheme.ThemePicker", selection: $settings.themeSelection) {
                ForEach(UserSettings.ThemeSelectionEnum.allCases, id: \.self) { theme in
                    Text(theme.shownName)
                        .tag(theme)
                }
            }
            .pickerStyle(.inline)
//            .labelsHidden()
        }
        #if os(iOS)
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Settings.InterfaceDesign.AccentTheme")
        #endif
        .onAppear {
//            selection = settings.accentColorIndex
            selection = settings.accentColorName
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .previewDevice("iPhone 12")
            .environmentObject(UserSettings())
            .environmentObject(StoreManager())
    }
}

