//
//  NightOwlModeView.swift.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 01.02.22.
//

import SwiftUI

struct NightOwlModeView: View {
    enum NightOwlCasesEnum: Int, CaseIterable, Hashable {
        case zero = 0
        case one = 1
        case two = 2
        case three = 3
        case four = 4
        case five = 5
    }
    
    @EnvironmentObject var userSettings: UserSettings
    
    @State private var helpOverlay: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            List() {
                Picker("Settings.Habits.NightOwl.Picker", selection: $userSettings.nightOwlHourSelection) {
                    ForEach(NightOwlCasesEnum.allCases, id: \.self) { hour in
                        Text("\(hour.rawValue) \(hour.rawValue == 1 ? "hour" : "hours")")
                            .tag(hour.rawValue)
                    }
                }
                .labelsHidden()
                .pickerStyle(InlinePickerStyle())
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings.Habits.NightOwl")
            .zIndex(1)
            
            
            if helpOverlay {
                VStack {
                    VStack(spacing: 5) {
                        Text("Settings.Habits.NightOwl")
                            .font(.headline)
                        
                        Text("Settings.Habits.NightOwl.Help.Body")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(.thickMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                    
                    Spacer()
                }
                .transition(.popUpScaleTransition)
                .frame(minWidth: 150, maxWidth: 350)
                .padding(50)
                .zIndex(2)
                .contentShape(Rectangle())
                .onTapGesture {
                    if helpOverlay {
                        withAnimation {
                            helpOverlay = false
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    if helpOverlay {
                        helpOverlay = false
                    } else {
                        helpOverlay = true
                    }
                } label: {
                    Label("General.Buttons.Help", systemImage: "info.circle")
                }
            }
        }
        
    }
}

struct NightOwlModeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                NightOwlModeView()
                    .environmentObject(UserSettings())
            }
//            NavigationView {
//                NightOwlModeView()
//                    .environmentObject(UserSettings())
//            }
//            .previewDevice("iPhone 13 mini")
            NavigationView {
                Text("test")
                NightOwlModeView()
                    .environmentObject(UserSettings())
            }
            .previewDevice("iPad Pro (11-inch) (3rd generation)")
.previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
