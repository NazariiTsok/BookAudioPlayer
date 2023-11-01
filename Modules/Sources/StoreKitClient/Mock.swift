import StoreKit

public class StoreKitClientMock: StoreKitClient {
    enum SubscriptionFailure: Error {
        case notImplemented
    }
        
    public var currentSubscription: Product {
        get async throws { throw SubscriptionFailure.notImplemented }
    }
    
    public var subscriptionStatus: Product.SubscriptionInfo.Status? {
        get async { return nil }
    }
    
    public func purchaseSubscription(for product: Product) throws -> Bool {
        // Mock implementation for purchasing a subscription
        return false
    }
    
    public func observeSubscriptionStatus() {
        // Mock implementation for observing subscription status
    }
    
    public func restorePurchases() {
        // Mock implementation for restoring purchases
    }
}
