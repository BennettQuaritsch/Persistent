//
//  SettingsView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 24.05.21.
//

import SwiftUI
import WidgetKit
import StoreKit

struct SettingsView: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var storeManager: StoreManager
    
    @State var syncEnabled: Bool
    
    @State var premiumSheet: Bool = false
    @State private var premiumNavigationActive: Bool = false
    
    @StateObject private var viewModel: SettingsViewModel = .init()
    
    init() {
        self._syncEnabled = State(wrappedValue: UserDefaults.standard.bool(forKey: "syncDisabled"))
    }
    
    var product: Product? {
        return storeManager.products.first(where: { $0.id == "quaritsch.bennnett.Persistent.premium.single" })
    }
    
    var body: some View {
        NavigationView {
            List {
                ZStack {
                    NavigationLink(destination: BuyPremiumView(), isActive: $premiumNavigationActive) {
                        EmptyView()
                    }
                    .hidden()
                    
                    Button {
                        premiumNavigationActive = true
                    } label: {
                        HStack {
                            Spacer()
                            
                            VStack(spacing: 10) {
                                Text("Persistent Premium")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.accentColor)
                                
                                Text("Buy Premium for \(product?.displayPrice ?? "unknown price")")
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                        }
                        .padding(10)
                    }
                    .buttonStyle(.plain)
                }
                
                Section("Interface Design") {
                    NavigationLink(destination: AccentColorSetting()) {
                        HStack {
                            Image(systemName: "paintbrush")
                                .foregroundColor(userSettings.accentColor)
                            
                            Text("Accent Color")
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            Image(systemName: "paintpalette")
                                .foregroundColor(userSettings.accentColor)
                            
                            Text("List cell colors")
                                .padding(.vertical, 5)
                        }
                        
                        Picker("List cell color", selection: $userSettings.simplerListCellColor) {
                            Text("Colorful").tag(false)
                            Text("Muted").tag(true)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    NavigationLink(destination: ChangeAppIconView()) {
                        HStack {
                            Image(systemName: "app")
                                .foregroundColor(userSettings.accentColor)
                            
                            Text("App Icon")
                        }
                    }
                    
                    Picker("Hand Preference", selection: $userSettings.leftHandedInterface) {
                        Text("Left Handed").tag(true)
                        Text("Right Handed").tag(false)
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Habits") {
                    NavigationLink(destination: NightOwlModeView()) {
                        HStack {
                            Image(systemName: "moon.stars")
                                .foregroundColor(userSettings.accentColor)
                            
                            Text("Night Owl Mode")
                        }
                    }
                    
                    NavigationLink(destination: ArchivedListView()) {
                        HStack {
                            Image(systemName: "archivebox")
                                .foregroundColor(userSettings.accentColor)
                            
                            Text("Archived Habits")
                        }
                    }
                }
                
                Section("Calendar") {
                    NavigationLink(destination: FirstWeekdayPickerView(settingsViewModel: viewModel)) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(userSettings.accentColor)
                            
                            Text("First Day of the Week")
                        }
                    }
                }
                
                Section("Sync") {
                    HStack {
                        Image(systemName: "icloud.fill")
                            .foregroundColor(userSettings.accentColor)
                        
                        Toggle("iCloud Sync", isOn: !$syncEnabled)
                            .onChange(of: syncEnabled) { value in
                                UserDefaults.standard.set(value, forKey: "syncDisabled")
                            }
                    }
                }
                
                Section("About") {
                    NavigationLink(destination: AboutAppView()) {
                        Label("About the app", systemImage: "info.circle.fill") 
                    }
                    
                    NavigationLink(destination: AboutPersistentView()) {
                        Label("Thanks to", systemImage: "hand.thumbsup.fill")
                    }
                }
                
                //NavigationLink("calendar", destination: CalendarPageViewController(toggle: .constant(true), habitDate: .constant(Date()), date: Date(), habit: previewTestHabit))
                
                #if DEBUG
                
                #endif
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
            .navigationBarTitle("Settings")
            #endif
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
            Picker("Select your preffered Color", selection: $selection) {
//                ForEach(0..<settings.colors.count) { index in
//                    HStack {
//                        RoundedRectangle(cornerRadius: 10)
//                            .fill(settings.colors[index].color)
//                            .scaledToFit()
//                            .frame(width: 30)
//                            .padding(.trailing, 5)
//
//                        Text("\(settings.colors[index].name)")
//                    }
//                }
                ForEach(settings.accentColorNames, id: \.self) { name in
                    HStack {
                        RoundedRectangle(cornerRadius: 10)
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
        }
        #if os(iOS)
        .listStyle(InsetGroupedListStyle())
        .navigationBarTitle("Accent Color")
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

