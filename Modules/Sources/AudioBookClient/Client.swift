
import Foundation
import Dependencies
import SharedFeature
import AVFoundation
import UIKit

extension AudioBookClient: DependencyKey {
    public static var liveValue: AudioBookClient = .live(bundle: .main)
}

extension DependencyValues {
    public var audioBookClient: AudioBookClient {
        get { self[AudioBookClient.self] }
        set { self[AudioBookClient.self] = newValue }
    }
}

public struct AudioBookClient: Sendable {
    public var load: @Sendable (_ id: String) async throws -> AudioBook
}

