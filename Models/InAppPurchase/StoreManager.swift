//
//  StoreManager.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 21.10.21.
//

import Foundation
import StoreKit
import SwiftKeychainWrapper

public enum StoreError: Error {
    case failedVerification
}

class StoreManager: ObservableObject {
    init() {
        self.updateListenerTask = listenForTransactions()
        
        Task {
            await requestProducts()
        }
    }
    
    enum TransactionState {
        case pending, success, failed
    }
    
    @Published private(set) var products: [Product] = []
    var transactionState: TransactionState?
    var updateListenerTask: Task<Void, Error>? = nil
    
    @MainActor
    func requestProducts() async {
        do {
            let storeProducts = try await Product.products(for: Set(["quaritsch.bennnett.Persistent.premium.single"]))
            
            self.products = storeProducts
        } catch {
            print("FetchError")
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            //UserDefaults.standard.setValue(true, forKey: transaction.productID)
            KeychainWrapper.standard.set(true, forKey: PurchaseEnum.isPurchasedIdentifier.rawValue)
            
            print("True set for \(transaction.productID)")
            
            await transaction.finish()
            
            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }
    
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        //Check if the transaction passes StoreKit verification.
        switch result {
        case .unverified:
            //StoreKit has parsed the JWS but failed verification. Don't deliver content to the user.
            throw StoreError.failedVerification
        case .verified(let safe):
            //If the transaction is verified, unwrap and return it.
            return safe
        }
    }
    
    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            //Iterate through any transactions which didn't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    
                    UserDefaults.standard.setValue(true, forKey: transaction.productID)
                    
                    print("True set for \(transaction.productID)")

                    //Deliver content to the user.
                    //await self.updatePurchasedIdentifiers(transaction)

                    //Always finish a transaction.
                    await transaction.finish()
                } catch {
                    //StoreKit has a receipt it can read but it failed verification. Don't deliver content to the user.
                    print("Transaction failed verification")
                }
            }
        }
    }
    
    func getEntitlements() async {
        print("getEntitlements")
        UserDefaults.standard.setValue(false, forKey: "quaritsch.bennnett.Persistent.premium.single")
        print("currentState: \(UserDefaults.standard.bool(forKey: "quaritsch.bennnett.Persistent.premium.single"))")
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                print("transaction: \(transaction.productID)")
                if transaction.productID == "quaritsch.bennnett.Persistent.premium.single" {
                    if transaction.revocationDate == nil {
                        UserDefaults.standard.setValue(true, forKey: transaction.productID)
                        print("entitlement true")
                    } else {
                        UserDefaults.standard.setValue(false, forKey: transaction.productID)
                        print("entitlement false")
                    }
                }
            case .unverified(let transaction, _):
                if transaction.productID == "quaritsch.bennnett.Persistent.premium.single" {
                    UserDefaults.standard.setValue(false, forKey: transaction.productID)
                    print("entitlement false")
                }
            }
        }
    }
    
    enum PurchaseEnum: String {
        case isPurchasedIdentifier = "isPurchasedIdentifier"
    }
    
    func getPurchaseEntitlement() async {
        KeychainWrapper.standard.set(false, forKey: PurchaseEnum.isPurchasedIdentifier.rawValue)
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                print("transaction: \(transaction.productID)")
                
                if transaction.productID == "quaritsch.bennnett.Persistent.premium.single" {
                    if transaction.revocationDate == nil {
                        KeychainWrapper.standard.set(true, forKey: PurchaseEnum.isPurchasedIdentifier.rawValue)
                        
                        print("entitlement true")
                    } else {
                        KeychainWrapper.standard.set(false, forKey: PurchaseEnum.isPurchasedIdentifier.rawValue)
                        
                        print("entitlement false")
                    }
                }
            case .unverified(let transaction, _):
                if transaction.productID == "quaritsch.bennnett.Persistent.premium.single" {
                    KeychainWrapper.standard.set(false, forKey: PurchaseEnum.isPurchasedIdentifier.rawValue)
                    print("entitlement false")
                }
            }
        }
    }
}
