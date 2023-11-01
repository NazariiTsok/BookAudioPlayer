import SwiftUI
import Dependencies
import Combine

public final class LivePremiumClient: PremiumClient {

    @PersistedValue public var isCurrentlyPremium: Bool {
        didSet {
            guard oldValue != isCurrentlyPremium else { return }
        }
    }

    public let isPremium: AnyPublisher<Bool, Never>

    public init(
        storage: UserDefaults = .sharedSchema
    ) {
        (_isCurrentlyPremium, isPremium) = storage.persistedBool(forKey: "is-premium-service-active").withPublisher()
    }
}
