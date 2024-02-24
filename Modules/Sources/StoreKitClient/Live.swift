
import Foundation
import StoreKit
import Combine
import PremiumClient

public final class StoreKitClientLive {
    private enum PaymentError: Error {
        case noSubscriptionLoaded
    }
    
    private let premiumService: PremiumClient
    
    private var purchasedProductIds: Set<String> = []
    private var availableSubscriptions: [Product] = []
    
    private var loadSubscriptionsTask: Task<Void, Never>?
    private var updatesTask: Task<Void, Never>?
    
    public init(premiumService: PremiumClient,
                purchasedProductIds: Set<String> = [],
                availableSubscriptions: [Product] = []
    ) {
        self.premiumService = premiumService
        self.purchasedProductIds = purchasedProductIds
        self.availableSubscriptions = availableSubscriptions
    }
    
    deinit {
        updatesTask?.cancel()
        loadSubscriptionsTask?.cancel()
    }
    
    private func loadInitialData() {
        Task(priority: .userInitiated) {
            await loadAvailableSubscriptionsIfNeeded()
            await updatePurchasedSubscriptionsWithCurrentEntitlements()
        }
    }
    
    private func updatePurchasedSubscriptionsWithCurrentEntitlements() async {
        for await result in Transaction.currentEntitlements {
            guard case let .verified(transaction) = result else { continue }
            updatePurchasedSubscriptions(for: transaction)
        }
        
        updatePremiumStateIfNeeded()
    }
    
    private func loadAvailableSubscriptionsIfNeeded() async {
        guard availableSubscriptions.isEmpty else { return  }
        
        let subscriptionIds = SubscriptionID.allCases.map(\.rawValue)
        
        do {
            let products = try await Product.products(for: subscriptionIds)
            
            availableSubscriptions = subscriptionIds.compactMap { id in
                products.first(where: { $0.id == id })
            }
        } catch {
            print("Failed to fetch products: \(error.localizedDescription)")
        }
    }
    
    private func listenForSubscriptionUpdates() {
        updatesTask?.cancel()
        updatesTask = Task(priority: .background) { [weak self] in
            for await result in Transaction.updates {
                guard case let .verified(transaction) = result else { continue }
                
                await transaction.finish()
                
                self?.updatePurchasedSubscriptions(for: transaction)
            }
        }
    }
    
    private func updatePurchasedSubscriptions(for transaction: Transaction) {
        if transaction.revocationDate == nil {
            print("Adding subscription to purchased: \(transaction.productID)")
            purchasedProductIds.insert(transaction.productID)
        } else {
            print("Removing subscription from purchased: \(transaction.productID)")
            purchasedProductIds.remove(transaction.productID)
        }
        
        updatePremiumStateIfNeeded()
    }
    
    private func updatePremiumStateIfNeeded() {
        let isCurrentlyPremium = purchasedProductIds.contains(SubscriptionID.yearly.rawValue)
        if isCurrentlyPremium != premiumService.isCurrentlyPremium {
            premiumService.isCurrentlyPremium = isCurrentlyPremium
        }
    }
}

extension StoreKitClientLive: StoreKitClient {
    
    public var currentSubscription: Product {
        get async throws {
            await loadAvailableSubscriptionsIfNeeded()
            
            guard let subscription = availableSubscriptions.first else {
                throw PaymentError.noSubscriptionLoaded
            }
            
            return subscription
        }
    }
    
    public var subscriptionStatus: Product.SubscriptionInfo.Status? {
        get async {
            let result = await Transaction.currentEntitlement(for: SubscriptionID.yearly.rawValue)
            guard case let .verified(transaction) = result else { return nil }
            return await transaction.subscriptionStatus
        }
    }
    
    public func observeSubscriptionStatus() {
        loadInitialData()
        listenForSubscriptionUpdates()
    }
    
    public func purchaseSubscription(for product: Product) async throws -> Bool {
        let result = try await product.purchase()
        
        switch result {
        case let .success(.verified(transaction)):
            print("Subscription purchase succeeded: \(transaction.productID)")
            await transaction.finish()
            updatePurchasedSubscriptions(for: transaction)
            return true
        case let .success(.unverified(transaction, error)):
            print("Subscription purchase failed: \(transaction.productID) \(error.localizedDescription)")
            return false
        case .pending:
            print("Subscription purchase pending: \(product.id)")
            return false
        case .userCancelled:
            return false
        @unknown default:
            return false
        }
    }
    
    public func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
            print("Failed to restore purchases: \(error.localizedDescription)")
        }
    }
}

private extension StoreKitClientLive {
    enum SubscriptionID: String, CaseIterable {
        case yearly = "headway.com.premium.subscription.yearly"
    }
}
