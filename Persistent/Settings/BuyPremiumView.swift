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
    @Environment(\.dismiss) var dismiss
    
    let premiumContents: [PremiumContent] = [
        .init(title: "More than 3 Habits", description: "You can create more than 3 habits at the same time. Time to power through them!", systemImageName: "checkmark.seal.fill"),
        .init(title: "View graphs", description: "Get a graphical look at how you did in the past. View a habit specificly or at all of them.", systemImageName: "chart.bar.xaxis")
    ]
    
    var product: Product? {
        return storeManager.products.first(where: { $0.id == "quaritsch.bennnett.Persistent.premium.single" })
    }
    
    @State var alert: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Image("persistentLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(minWidth: 50, maxWidth: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
                
                    ScrollView() {
                        GeometryReader { geo in
                            VStack(alignment: .leading, spacing: 30) {
                                ForEach(premiumContents, id: \.self) { content in
                                    HStack(spacing: 0) {
                                        Image(systemName: content.systemImageName)
                                            .resizable()
                                            .scaledToFill()
                                            .foregroundColor(.accentColor)
                                        #if os(iOS)
                                            .frame(width: horizontalSizeClass == .regular ? geo.size.width * 0.1 : geo.size.width * 0.2)
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
                    }
                    .padding(.vertical)
                
                if UserDefaults.standard.bool(forKey: product?.id ?? "") {
                    Text("Purchased")
                } else {
                    Button {
                        if let product = product {
                            Task {
                                do {
                                    if try await storeManager.purchase(product) != nil {
                                        print("bought")
                                        dismiss()
                                    } else {
                                        print("not bought")
                                    }
                                } catch {
                                    print("error")
                                }
                            }
                        }
                    } label: {
                        if storeManager.transactionState == .pending {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Buy Persistent for \(product?.displayPrice ?? "unknown price")")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                    }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                    
                    Button("Restore Purchases") {
                        //storeManager.restoreProducts()
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
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
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
}

struct BuyPremiumView_Previews: PreviewProvider {
    static var previews: some View {
        BuyPremiumView()
            .environmentObject(StoreManager())
    }
}
