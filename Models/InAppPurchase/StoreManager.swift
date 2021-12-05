//
//  StoreManager.swift
//  Persistent
//
//  Created by Bennett Quaritsch on 21.10.21.
//

import Foundation
import StoreKit

public enum StoreError: Error {
    case failedVerification
}

class StoreManagerDeprecated: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @Published var myProducts = [SKProduct]()
    @Published var transactionState: SKPaymentTransactionState?
    
    var request: SKProductsRequest!
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Did receive response")
            
        if !response.products.isEmpty {
            for fetchedProduct in response.products {
                DispatchQueue.main.async {
                    self.myProducts.append(fetchedProduct)
                }
            }
        }
        
        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid identifiers found: \(invalidIdentifier)")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Request did fail: \(error)")
    }
    
    func getProducts(productIDs: [String]) {
        print("Start requesting products ...")
        let request = SKProductsRequest(productIdentifiers: Set(productIDs))
        request.delegate = self
        request.start()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                transactionState = .purchasing
            case .purchased:
                UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                transactionState = .purchased
                print("purchased \(transaction.payment.productIdentifier)")
            case .restored:
                UserDefaults.standard.setValue(true, forKey: transaction.payment.productIdentifier)
                queue.finishTransaction(transaction)
                transactionState = .restored
            case .failed, .deferred:
                print("Payment Queue Error: \(String(describing: transaction.error))")
                queue.finishTransaction(transaction)
                transactionState = .failed
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print(error)
    }
    
    func purchaseProduct(product: SKProduct) {
        if SKPaymentQueue.canMakePayments() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            print("User can't make payment.")
        }
    }
    
    func restoreProducts() {
        print("Restoring products ...")
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
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
            
            UserDefaults.standard.setValue(true, forKey: transaction.productID)
            
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
}
