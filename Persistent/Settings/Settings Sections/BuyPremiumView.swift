//
//  BuyPremiumView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 21.10.21.
//

import SwiftUI
import StoreKit
import WidgetKit

struct PremiumContent: Identifiable {
    var title: String
    var description: LocalizedStringKey
    var systemImageName: String
    
    var titleLocalized: LocalizedStringKey {
        LocalizedStringKey(title)
    }
    
    var id: String {
        return title
    }
}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}

struct BuyPremiumView: View {
    @EnvironmentObject private var storeManager: StoreManager
    #if os(iOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
    @Environment(\.purchaseInfo) var purchaseInfo
    @Environment(\.dismiss) var dismiss
    
    let premiumContents: [PremiumContent] = [
        .init(title: "Settings.PersistentPremium.MoreHabits.Title", description: "Settings.PersistentPremium.MoreHabits.Description", systemImageName: "checkmark.seal.fill"),
        .init(title: "Settings.PersistentPremium.Graphs.Title", description: "Settings.PersistentPremium.Graphs.Description", systemImageName: "chart.bar.xaxis"),
        .init(title: "Settings.PersistentPremium.Notifications.Title", description: "Settings.PersistentPremium.Notifications.Description", systemImageName: "bell.badge.fill"),
        .init(title: "Settings.PersistentPremium.Support.Title", description: "Settings.PersistentPremium.Support.Description", systemImageName: "heart.fill")
    ]
    
    var product: Product? {
        return storeManager.products.first(where: { $0.id == "quaritsch.bennnett.Persistent.premium.single" })
    }
    
    @State var alert: Bool = false
    
    @State private var purchasing: Bool = false
    
    @ScaledMetric(relativeTo: .title3) var buttonHeight = 40
    
    var body: some View {
        VStack {
            Image("persistentLogo")
                .resizable()
                .scaledToFit()
                .frame(minWidth: 80, maxWidth: 120)
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(premiumContents) { content in
                        HStack(spacing: 0) {
                            Image(systemName: content.systemImageName)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.accentColor)
                            #if os(iOS)
                                .frame(width: 40)
                                .padding(.trailing)
                            #endif
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text(content.titleLocalized)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text(content.description)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
            }
            .padding(.vertical)
            
            if purchaseInfo.wrappedValue {
                Text("Settings.PersistentPremium.BoughtText")
                    .font(.headline)
                    .padding()
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
            } else {
                Button {
                    if let product = product {
                        Task {
                            purchasing = true
                            
                            do {
                                if try await storeManager.purchase(product) != nil {
                                    print("bought")
                                    purchaseInfo.wrappedValue = true
                                    dismiss()
                                } else {
                                    print("not bought")
                                }
                            } catch {
                                print("error")
                                alert = true
                            }
                            
                            purchasing = false
                            
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                    }
                } label: {
                    if purchasing {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .frame(height: buttonHeight)
                    } else {
                        Text("Settings.PersistentPremium.BuyNowText \(product?.displayPrice ?? NSLocalizedString("Settings.PersistentPremium.BuyNowText.unknowPrice", comment: ""))")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .frame(height: buttonHeight)
                    }
                }
                
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                
                Button("Settings.PersistentPremium.RestorePurchase") {
                    //storeManager.restoreProducts()
                    Task {
                        await storeManager.getEntitlements()
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }
        }
        .padding()
        #if os(iOS)
        .navigationTitle("Settings.PersistentPremium.Header")
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .onChange(of: storeManager.transactionState) { state in
            switch state {
            case .success:
                dismiss()
            case .failed:
                print("failed")
                alert = true
            default:
                print("Nichts passiert")
            }
        }
        .alert(isPresented: $alert) {
            Alert(title: Text("Settings.PersistentPremium.Error.Title"), message: Text("Settings.PersistentPremium.Error.Description"), dismissButton: .cancel())
        }
    }
}

struct BuyPremiumView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BuyPremiumView()
                .environmentObject(StoreManager())
            
            VStack {
                
            }
                .sheet(isPresented: .constant(true), content: {
                    BuyPremiumView()
                })
                .previewDevice("iPad Pro (12.9-inch) (5th generation)")
                .environmentObject(StoreManager())
.previewInterfaceOrientation(.landscapeLeft)
        }
    }
}
