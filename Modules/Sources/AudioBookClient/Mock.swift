import Foundation
import XCTestDynamicOverlay
import Dependencies

extension AudioBookClient: TestDependencyKey {
    public static let testValue = Self(
        load: unimplemented()
    )
}
