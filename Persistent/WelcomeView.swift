//
//  WhatsNewView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 04.01.22.
//

import SwiftUI

struct WelcomeView: View {
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    
    @Environment(\.dismiss) var dismiss
    
    let welcomeItems: [PremiumContent] = [
        .init(title: "Add habit", description: "Add a habit by pressing the plus button in the lower right (or left) corner.", systemImageName: "plus"),
        .init(title: "Detailed view", description: "Click on the habits in the list to view them in detail.", systemImageName: "magnifyingglass"),
        .init(title: "Context menus", description: "Long press on a habit in the list to see a context menu.", systemImageName: "ellipsis.circle")
    ]
    var body: some View {
        VStack {
            Spacer()
                .frame(minHeight: 20, maxHeight: 60)
                .layoutPriority(1)
            
            Text("Welcome to Persistent")
                .font(.system(size: 45))
                .fontWeight(.heavy)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.6)
                .layoutPriority(2)
            
            VStack(alignment: .leading, spacing: 30) {
                ForEach(welcomeItems, id: \.self) { content in
                    HStack(spacing: 0) {
                        Image(systemName: content.systemImageName)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.accentColor)
                        #if os(iOS)
                            .frame(width: 35)
                            .padding(.trailing)
                        #endif
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(content.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(content.description)
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .layoutPriority(1)
            
            VStack {
                Text("Explore the rest yourself!")
                    .padding(.bottom, 1)
                
                Text("Have fun!")
            }
            .font(.title3.weight(.semibold))
            .padding()
            .layoutPriority(1)
            
            Spacer(minLength: 30)
                .layoutPriority(0)
            
            Button {
                dismiss()
            } label: {
                Text("Get started")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.bottom)
            
        }
        .padding()
    }
}

struct AlternativeWelcomeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var tabIndex: Int = 1
    
    var body: some View {
        TabView(selection: $tabIndex) {
            VStack {
                GeometryReader { geo in
                    VStack {
                        Image("persistentLogo")
                            .resizable()
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
                        
                        Text("Welcome to Persistent!")
                            .font(.largeTitle.weight(.bold))
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                        
                        Text("Build healthy habits and get straight to the point. Set notifications, so you won´t miss them and view your statistics.")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                
                Button("Give me an introduction") {
                    withAnimation(.easeInOut) {
                        tabIndex = 2
                    }
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .font(.body.weight(.semibold))
                
                Button("Skip intoduction") {
                    dismiss()
                }
                .buttonStyle(.bordered)
            }
            .padding()
            .padding(horizontalSizeClass == .regular ? 50 : 0)
            .padding(.bottom, 50)
            .tag(1)
            
            GeometryReader { geo in
                VStack {
                    if horizontalSizeClass == .regular {
                        Text("You will find your habits in the list view.")
                            .font(.headline)
                        
                        Image("WelcomeViewIPadScreenshot")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: geo.size.width)
                            .shadow(radius: 5)
                            .padding()
                        
                        Group {
                            Text("Filter and sort your habits through the ")
                            + Text("sidebar on the left")
                                .foregroundColor(.primary)
                                .fontWeight(.semibold)
                            + Text(". Click the different buttons to filter your habits to your linking. Add them by pressing the ")
                            + Text("plus button.")
                                .foregroundColor(.primary)
                                .fontWeight(.semibold)
                        }
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    } else {
                        Text("You will find your habits in the list view.")
                            .font(.headline)
                        
                        Image("WelcomeViewIPhoneScreenshot")
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: geo.size.height * 0.7)
                            .shadow(radius: 5)
                            .padding()
                        
                        Group {
                            Text("Filter and sort your habits through the ")
                            + Text("menu in the upper left corner")
                                .foregroundColor(.primary)
                                .fontWeight(.semibold)
                            + Text(". Add them by pressing the ")
                            + Text("plus button.")
                                .foregroundColor(.primary)
                                .fontWeight(.semibold)
                        }
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                
            }
            .padding()
            .padding(horizontalSizeClass == .regular ? 50 : 0)
            .padding(.bottom, 30)
            .tag(2)
            
            GeometryReader { geo in
                VStack {
                    Text("Use Context Menus")
                        .font(.headline)
                    
                    Image("ContextMenuScreenshot")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: geo.size.width * 0.6)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .shadow(radius: 5)
                        .padding()
                    
                    Group {
                        Text("For this, ")
                        + Text("long press on the habits")
                            .foregroundColor(.primary)
                            .fontWeight(.semibold)
                        + Text(". You can also ")
                        + Text("press on the count of the habit in the detail view")
                            .foregroundColor(.primary)
                            .fontWeight(.semibold)
                        + Text(", find out what that does yourself!")
                    }
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .padding()
            .padding(horizontalSizeClass == .regular ? 50 : 0)
            .tag(3)
            
            VStack {
                GeometryReader { geo in
                    VStack {
                        if horizontalSizeClass == .regular {
                            Text("Now build healthy habits yourself!")
                                .font(.headline)
                            
                            Image("WelcomeViewIPadDetailViewScreenshot")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: geo.size.width)
                                .shadow(radius: 5)
                                .padding()
                        } else {
                            Text("Now build healthy habits yourself!")
                                .font(.headline)
                            
                            Image("WelcomeViewDetailViewScreenshot")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: geo.size.height * 0.7)
                                .shadow(radius: 5)
                                .padding()
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
                
                Button("Get started!") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .font(.body.weight(.semibold))
            }
            .padding()
            .padding(horizontalSizeClass == .regular ? 50 : 0)
            .padding(.bottom, 50)
            .tag(4)
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
//            WelcomeView()
            
            AlternativeWelcomeView()
            
            VStack{
                
            }
                .sheet(isPresented: .constant(true)) {
                    AlternativeWelcomeView()
                }
                .previewDevice("iPad Pro (12.9-inch) (5th generation)")
.previewInterfaceOrientation(.landscapeLeft)
            
//            VStack{
//
//            }
//                .sheet(isPresented: .constant(true)) {
//                    AlternativeWelcomeView()
//                }
//                .previewDevice("iPhone 13 mini")
            
//            WelcomeView()
//                .previewDevice("iPhone 8")
//
//            WelcomeView()
//                .previewDevice("iPhone 13 mini")
//            WhatsNewView()
//                .previewDevice("iPad Pro (12.9-inch) (5th generation)")
        }
    }
}
