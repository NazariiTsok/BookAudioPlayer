import SwiftUI
import Dependencies
import Combine

extension DependencyValues {
    public var premiumClient: any PremiumClient {
        get { self[PremiumServiceKey.self] }
        set { self[PremiumServiceKey.self] = newValue }
    }
}

public protocol PremiumClient: AnyObject {
    var isCurrentlyPremium: Bool { get set }
    var isPremium: AnyPublisher<Bool, Never> { get }
}

private enum PremiumServiceKey: DependencyKey {
    static let liveValue: any PremiumClient = {
        return LivePremiumClient()
    }()

    static let previewValue: any PremiumClient = PremiumClientMock(isPremium: true)
    static let testValue: any PremiumClient = PremiumClientMock()
}






