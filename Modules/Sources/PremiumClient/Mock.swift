import SwiftUI
import Dependencies
import Combine

public final class PremiumClientMock: PremiumClient {
    public let _isPremium: CurrentValueSubject<Bool, Never>

    public var isCurrentlyPremium: Bool {
        get { _isPremium.value }
        set { _isPremium.value = newValue }
    }

    public var isPremium: AnyPublisher<Bool, Never> {
        _isPremium.eraseToAnyPublisher()
    }

    public init(isPremium: Bool = false) {
        self._isPremium = CurrentValueSubject(isPremium)
    }
}

