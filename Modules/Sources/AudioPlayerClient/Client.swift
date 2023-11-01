@preconcurrency
import AVFoundation
import Dependencies
import Foundation
import XCTestDynamicOverlay
import SharedFeature


public struct AudioPlayerClient: Sendable {
    
    public var load: @Sendable (_ url: URL) async throws -> Void
    
    public let setRate: @Sendable (Float) async -> Void
    
    public let play: @Sendable () async -> Void
    
    public let pause: @Sendable () async -> Void
    
    public let seek: @Sendable (_ progress: Double) async -> Void
    
    public let clear: @Sendable () async -> Void
        
    public let player: AVPlayer
}

public extension DependencyValues {
    var audioPlayerClient: AudioPlayerClient {
        get { self[AudioPlayerClient.self] }
        set { self[AudioPlayerClient.self] = newValue }
    }
}
