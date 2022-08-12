//
//  ChooseIconView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 07.02.22.
//

import SwiftUI

struct ChooseIconView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.openURL) private var openURL
    
    let columns = [GridItem(.adaptive(minimum: 60, maximum: 80))]
    
    @Binding var iconChoice: String
    
    @State var selections: [String: Bool] = ["Sport": true]
//    @Binding var sections: [IconSection]
    @State private var sections: [IconSection] = IconSection.sections
    
    @State private var helpShown: Bool = false
    
    var body: some View {
        ZStack {
            Color("systemGray6")
                .edgesIgnoringSafeArea(.all)
                .zIndex(0)
            
            ScrollView {
                ForEach($sections, id: \.self) { $section in
                    VStack {
                        HStack {
                            Text(section.name)
                                .font(.title2)
                                .fontWeight(.bold)

                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .rotationEffect(.degrees(section.isSelected ? 90 : 0))
                                .transaction { transaction in
                                    transaction.disablesAnimations = true
                                }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.75, blendDuration: 1)) {
                                section.isSelected.toggle()
                                
                                UserDefaults.standard.set(section.isSelected, forKey: section.name + IconSection.userDefaultsKey)
                            }
                        }
                        
                        if section.isSelected {
                            LazyVGrid(columns: columns, alignment: .center, spacing: 10) {
                                ForEach(section.iconArray, id: \.self) { icon in
                                    Button {
                                        iconChoice = icon
                                        presentationMode.wrappedValue.dismiss()
                                    } label: {
                                        ZStack {
                                            Image(icon)
                                                .resizable()
                                                .scaledToFit()
                                                .foregroundColor(.primary.opacity(0.7))
                                                .padding(8)
                                                .accessibility(label: Text(icon))
                                            
                                            if icon == iconChoice {
                                                RoundedRectangle(cornerRadius: 15, style: .continuous)
                                                    .strokeBorder(Color.accentColor, lineWidth: 5)
                                            }
                                        }
                                    }
                                }
                            }
                            .transition(.asymmetric(insertion: .opacity.animation(.easeInOut(duration: 0.3)), removal: .opacity.animation(.easeInOut(duration: 0.2))))
                        }
                            
                    }
                    .padding(.bottom)
                }
                .zIndex(1)
                .padding()
            }
            .disabled(helpShown)
            
            if helpShown {
                VStack {
                    Spacer()
                    
                    VStack {
                        Text("Icon missing?")
                            .font(.headline)
                            .padding(.bottom, 1)
                        
                        Text("If you feel like Persistent misses some icons, feel free to write me an e-mail with your suggestions.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("E-Mail") {
                            guard let url = URL(string: "mailto:support@persistentapp.net?subject=Icon%20Request&body=I%20think%20following%20icons%20would%20be%20a%20good%20addition:") else { return }
                            
                            openURL(url)
                        }
                        .buttonStyle(.bordered)
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
                    if helpShown {
                        withAnimation {
                            helpShown = false
                        }
                    }
                }
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationTitle("Choose Icon")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    helpShown.toggle()
                } label: {
                    Label("Help", systemImage: "questionmark")
                }
            }
        }
    }
}

struct ChooseIconView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ChooseIconView(iconChoice: .constant("person"))
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
