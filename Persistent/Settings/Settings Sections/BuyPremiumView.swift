//
//  BuyPremiumView.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 21.10.21.
//

import SwiftUI
import StoreKit

struct PremiumContent: Hashable {
    var title: String
    var description: String
    var systemImageName: String
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
        .init(title: "More than 3 Habits", description: "You can create more than 3 habits at the same time. Time to power through them!", systemImageName: "checkmark.seal.fill"),
        .init(title: "View graphs", description: "Get a graphical look at how you did in the past. Click on the graphs icon in the detail page of your habit.", systemImageName: "chart.bar.xaxis"),
        .init(title: "Notifications", description: "Schedule notifications that remind you of your habit.", systemImageName: "bell.badge.fill"),
        .init(title: "Support", description: "With this purchase you can support me, an indie app-creator 😊.", systemImageName: "heart.fill")
    ]
    
    var product: Product? {
        return storeManager.products.first(where: { $0.id == "quaritsch.bennnett.Persistent.premium.single" })
    }
    
    @State var alert: Bool = false
    
    @State private var purchasing: Bool = false
    
    var body: some View {
        VStack {
            Image("persistentLogo")
                .resizable()
                .scaledToFit()
                .frame(minWidth: 80, maxWidth: 120)
                .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 30) {
                    ForEach(premiumContents, id: \.self) { content in
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
            }
            .padding(.vertical)
            
            if purchaseInfo.wrappedValue {
                Text("Purchased")
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
                        }
                    }
                } label: {
                    if purchasing {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Buy Premium for \(product?.displayPrice ?? "unknown price")")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                
                Button("Restore Purchases") {
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
        .navigationTitle("Premium")
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
            Alert(title: Text("Something went wrong"), message: Text("This might have been your connection or I made a mistake. If this keeps happening, please reach out to me."), dismissButton: .cancel())
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
