import Foundation
import StoreKit
import Dependencies
import Combine

public protocol StoreKitClient {
    
    var currentSubscription: Product { get async throws }
    var subscriptionStatus: Product.SubscriptionInfo.Status? { get async }
    
    @discardableResult
    func purchaseSubscription(for product: Product) async throws -> Bool
    
    func observeSubscriptionStatus()
    func restorePurchases() async
}

extension DependencyValues {
    public var storeKitClient: StoreKitClient {
        get { self[StoreKitClientKey.self] }
        set { self[StoreKitClientKey.self] = newValue }
    }
}

private enum StoreKitClientKey: DependencyKey {
    public static let liveValue: any StoreKitClient = {
        @Dependency(\.premiumClient) var premiumService
        return StoreKitClientLive(premiumService: premiumService)
    }()
    
    public static let previewValue: any StoreKitClient = StoreKitClientMock()
}






