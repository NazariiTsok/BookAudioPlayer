import Foundation
import XCTestDynamicOverlay
import Dependencies

extension AudioPlayerClient: TestDependencyKey {
    public static let testValue = Self(
        load: unimplemented(),
        setRate: unimplemented(),
        play: unimplemented(),
        pause: unimplemented(),
        seek: unimplemented(),
        clear: unimplemented(),
        player: unimplemented()
    )
}
