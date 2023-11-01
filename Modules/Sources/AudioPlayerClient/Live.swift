import AVFAudio
import AVKit
import Foundation
import SwiftUI
import Combine
import ComposableArchitecture
import SharedFeature
import AVFoundation
import UIKit

extension AudioPlayerClient: DependencyKey {
    public static var liveValue: AudioPlayerClient = .live(bundle: .main)
}

extension AudioPlayerClient {
    public static func live(bundle: Bundle) -> Self {
        let audioPlayer = InternalAudioPlayer(bundle: bundle)
        
        return Self(
            load: { @MainActor url in try await audioPlayer.load(url) },
            setRate: { @MainActor rate in audioPlayer.setRate(rate) },
            play: { @MainActor in await audioPlayer.play() },
            pause: { @MainActor in await audioPlayer.pause() },
            seek: { @MainActor progress in await audioPlayer.seek(to: progress) },
            clear: { @MainActor in await audioPlayer.clear() },
            player: audioPlayer.player
        )
    }
}


private class InternalAudioPlayer {
    
    enum Failure: Error {
        case fileNotFound
        case noAvailableLocales
    }
    
    let bundle: Bundle
    let player: AVQueuePlayer
    
    private let session: AVAudioSession
    
    init(bundle: Bundle) {
        self.bundle = bundle
        
        self.player = .init()
        
        self.session = AVAudioSession.sharedInstance()
        try? session.setCategory(
            .playback,
            mode: .moviePlayback,
            policy: .longFormAudio
        )
        
        player.allowsExternalPlayback = true
        player.automaticallyWaitsToMinimizeStalling = true
        player.preventsDisplaySleepDuringVideoPlayback = true
        player.actionAtItemEnd = .pause
        player.appliesMediaSelectionCriteriaAutomatically = true
    }
    
    @MainActor
    func load(_ url: URL) async throws {
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        player.replaceCurrentItem(with: playerItem)
        
        try? session.setActive(true)
    }
    
    @MainActor
    func setRate(_ rate: Float) {
        player.rate = rate
    }
    
    @MainActor
    func play() async {
        player.play()
    }
    
    @MainActor
    func pause() async {
        player.pause()
    }
    
    @MainActor
    func seek(to progress: Double) async  {
        if let duration = player.currentItem?.duration, duration.seconds > .zero {
            await player.seek(
                to: .init(
                    seconds: duration.seconds * progress,
                    preferredTimescale: CMTimeScale(NSEC_PER_SEC)
                ),
                toleranceBefore: .zero,
                toleranceAfter: .zero
            )
        }
    }
    
    @MainActor
    func clear() async {
        player.pause()
        player.removeAllItems()
        try? session.setActive(false, options: .notifyOthersOnDeactivation)
    }
}

