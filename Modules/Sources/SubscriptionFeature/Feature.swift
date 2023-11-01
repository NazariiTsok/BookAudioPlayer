import SwiftUI
import ComposableArchitecture
import StoreKit
import StoreKitClient

public struct SubscriptionFeature: Reducer {
    public enum State: Equatable {
        case loading
        case failure
        case available(Product, Product.SubscriptionInfo, isEligibleForIntroOffer: Bool)
        
        public init() {
            self = .loading
        }
    }
    
    public enum Action: Equatable {
        case paymentButtonTapped
        
        case loadSubscription
        case subscriptionLoaded(product: Product, subscription: Product.SubscriptionInfo, isEligibleForIntroOffer: Bool)
        case subscriptionLoadFailed
    }
    
    public init() {}
    
    @Dependency(\.storeKitClient) var storeKitClient
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadSubscription:
                
                state = .loading
                return .run { send in
                    let product = try await storeKitClient.currentSubscription
                    
                    guard let subscription = product.subscription else {
                        await send(.subscriptionLoadFailed)
                        return
                    }
                    
                    let isEligibleForIntroOffer = await subscription.isEligibleForIntroOffer
                    
                    await send(.subscriptionLoaded(
                        product: product,
                        subscription: subscription,
                        isEligibleForIntroOffer: isEligibleForIntroOffer)
                    )
                } catch: { _, send in
                    await send(.subscriptionLoadFailed)
                }
            case let .subscriptionLoaded(product,subscription,isEligibleForIntroOffer):
                state = .available(product, subscription, isEligibleForIntroOffer: isEligibleForIntroOffer)
                return .none
            case .paymentButtonTapped:
                guard case let .available(product, _, _) = state else { return .none }
                return .run { _ in
                    try await storeKitClient.purchaseSubscription(for: product)
                    
                }
            case .subscriptionLoadFailed:
                state = .failure
                return .none
            }
        }
    }
}
