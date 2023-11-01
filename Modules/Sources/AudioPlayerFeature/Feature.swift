
import Foundation
import SwiftUI
import ComposableArchitecture
import SharedFeature
import AVKit
import UIKit
import AudioPlayerClient
import AudioBookClient

public struct AudioPlayerState: Equatable {
    public var status: AVPlayer.Status
    public var timeControlStatus: AVPlayer.TimeControlStatus
    
    public var isPlaybackBufferEmpty: Bool
    public var isPlaybackBufferFull: Bool
    public var isPlaybackLikelyToKeepUp: Bool
    
    public var rate: Float
    public var progress: CMTime
    public var duration: CMTime
    
    public var isPlaying:Bool {
        timeControlStatus == .playing ||
        timeControlStatus == .waitingToPlayAtSpecifiedRate
    }
    
    public var isBuffering: Bool {
        !isPlaybackBufferFull && isPlaybackBufferEmpty || !isPlaybackLikelyToKeepUp
    }
    
    public init(
        status: AVPlayer.Status = .unknown,
        timeControlStatus: AVPlayer.TimeControlStatus = .waitingToPlayAtSpecifiedRate,
        isPlaybackBufferEmpty: Bool = true,
        isPlaybackBufferFull: Bool = false,
        isPlaybackLikelyToKeepUp: Bool = false,
        rate: Float = 1.0,
        progress: CMTime = .zero,
        duration: CMTime = .zero
    ) {
        self.status = status
        self.timeControlStatus = timeControlStatus
        self.isPlaybackBufferEmpty = isPlaybackBufferEmpty
        self.isPlaybackBufferFull = isPlaybackBufferFull
        self.isPlaybackLikelyToKeepUp = isPlaybackLikelyToKeepUp
        self.rate = rate
        self.progress = progress
        self.duration = duration
    }
}


extension AudioPlayerFeature.State {
    public var placeholderItem: Chapter {
        return Chapter(id: .init(), title: .init(), startsAt: .init(), endsAt: .init(), duration: 1.0)
    }
    
    public var isSliderEnabled:Bool {
        audioPlayerState.duration.isValid &&
        !audioPlayerState.duration.seconds.isNaN &&
        audioPlayerState.duration != .zero
    }
    
    public  var artworkPreview:Data? {
        return audiobook.value?.preview
    }
    
    public var chapterCount: Int {
        return audiobook.value?.chapters.count ?? .zero
    }
    
    public var currentChapter:Chapter {
        return audiobook.value?.chapters.first(where: {
            progress >= $0.startsAt && progress <= $0.endsAt
        }) ?? placeholderItem
    }
    
    public  var currentChapterTitle: String {
        return self.currentChapter.title
    }
    
    public  var currentChapterIndex:Int {
        return (audiobook.value?.chapters.firstIndex(where: { $0.id == self.currentChapter.id }) ?? .zero)
    }
    
    public var hasNextChapter: Bool {
        let chaptersCount = audiobook.value?.chapters.count ?? .zero
        return currentChapterIndex < chaptersCount - 1
    }
    
    public var hasPreviousChapter:Bool {
        self.currentChapterIndex > 0
    }
    
    public var rateValues: [Float] {
        return [0.50, 0.75, 1.0, 1.25, 1.50 ,1.75, 2.0]
    }
    
    public var isPlaying:Bool {
        return audioPlayerState.isPlaying
    }
    
    public var isBuffering:Bool {
        return audioPlayerState.isBuffering
    }
    
    public var progress:Double {
        return audioPlayerState.progress.seconds
    }
    
    public var rate: Float {
        return audioPlayerState.rate
    }
    
    public var totalChaptersCount: Int {
        return audiobook.value?.chapters.count ?? .zero
    }
    
    public var isLastChapter: Bool {
        let chaptersCount = audiobook.value?.chapters.count ?? .zero
        return currentChapterIndex == chaptersCount - 1
    }
}


public struct AudioPlayerFeature: Reducer{
    public struct State: Equatable {
        
        @PresentationState public var alert: AlertState<Action.Alert>?
        
        public var audioBookId: String
        public var audioPlayerState:AudioPlayerState
        
        public var audiobook: Loadable<AudioBook>
        
        public init(
            audioBookId: String,
            audiobook: Loadable<AudioBook> = .initial,
            alert: AlertState<Action.Alert>? = nil,
            audioPlayerState: AudioPlayerState = .init()
        ){
            
            self.audioBookId = audioBookId
            self.audioPlayerState = audioPlayerState
            
            self.audiobook = audiobook
            self.alert = alert            
        }
    }
    
    public enum Action: Equatable {
        //MARK: Player Actions
        
        public enum ViewAction: Equatable {
            case didAppear
            case didTapGoForwards
            case didTapGoBackwards
            case didTogglePlayButton
            case didStartedSeeking
            case didFinishedSeekingTo(CGFloat)
            case didTapSubtitle(for: AVMediaSelectionGroup, AVMediaSelectionOption?)
            case didSelectRate(Float)
            case didAudioBookLoaded(TaskResult<AudioBook>)
            case didTapGoToPrevious
            case didTapGoToNext
        }
        
        public enum InternalAction: Equatable {
            case status(AVPlayer.Status)
            case rate(Float)
            case progress(CMTime)
            case duration(CMTime)
            case timeControlStatus(AVPlayer.TimeControlStatus)
            case playbackBufferFull(Bool)
            case playbackBufferEmpty(Bool)
            case playbackLikelyToKeepUp(Bool)
            
        }
        
        case alert(PresentationAction<Alert>)
        
        public enum Alert: Equatable {
            case openSettingButtonTapped
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        
    }
    
    public init() {}
    
    @Dependency(\.audioPlayerClient) var audioPlayerClient
    @Dependency(\.audioBookClient) var audioBookClient
    @Dependency(\.continuousClock) var clock
    
    enum CancellableID: Hashable {
        case initialize
        case debounce
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state , action in
            switch action {
            case .view(.didAppear):
                state.audiobook = .loading
                
                return .run { [audioBookId = state.audioBookId] send in
                    await withTaskCancellation(id: CancellableID.initialize) {
                        await withTaskGroup(of: Void.self) { group in
                            group.addTask {
                                await send(.view(.didAudioBookLoaded(
                                    TaskResult {
                                        try await audioBookClient.load(audioBookId) }))
                                )
                            }
                            
                            group.addTask {
                                for await rate in audioPlayerClient.player.valueStream(\.rate) {
                                    await send(.internal(.rate(rate)))
                                }
                            }
                            
                            group.addTask {
                                for await time in audioPlayerClient.player.periodicTimeStream() {
                                    await send(.internal(.progress(time)))
                                }
                            }
                            
                            group.addTask {
                                for await time in audioPlayerClient.player.valueStream(\.currentItem?.duration) {
                                    await send(.internal(.duration(time ?? .zero)))
                                }
                            }
                            
                            group.addTask {
                                for await status in audioPlayerClient.player.valueStream(\.status) {
                                    await send(.internal(.status(status)))
                                }
                            }
                            
                            group.addTask {
                                for await status in audioPlayerClient.player.valueStream(\.timeControlStatus) {
                                    await send(.internal(.timeControlStatus(status)))
                                }
                            }
                            
                            group.addTask {
                                for await empty in audioPlayerClient.player.valueStream(\.currentItem?.isPlaybackBufferEmpty) {
                                    await send(.internal(.playbackBufferEmpty(empty ?? true)))
                                }
                            }
                            
                            group.addTask {
                                for await full in audioPlayerClient.player.valueStream(\.currentItem?.isPlaybackBufferFull) {
                                    await send(.internal(.playbackBufferFull(full ?? false)))
                                }
                            }
                            
                            group.addTask {
                                for await canKeepUp in audioPlayerClient.player.valueStream(\.currentItem?.isPlaybackLikelyToKeepUp) {
                                    await send(.internal(.playbackLikelyToKeepUp(canKeepUp ?? false)))
                                }
                            }
                        }
                    }
                }
            case let .view(.didAudioBookLoaded(.success(value))):
                state.audiobook = .loaded(value)
                
                guard let url = state.audiobook.value?.assetUrl else {
                    return .none
                }
                
                return .run {  _ in
                    try await self.audioPlayerClient.load(url)
                }
            case let .view(.didAudioBookLoaded(.failure(error))):
                state.audiobook = .failed(error)
                return .none
            case .view(.didTogglePlayButton):
                return .run { [isPlaying = state.audioPlayerState.isPlaying ]  _ in
                    await isPlaying ? audioPlayerClient.pause() : audioPlayerClient.play()
                }
            case .view(.didTapGoBackwards):
                let newProgress = max(0, state.audioPlayerState.progress.seconds - 5)
                let duration = state.audioPlayerState.duration.seconds
                state.audioPlayerState.progress = .init(seconds: newProgress, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                return .run { _ in
                    await audioPlayerClient.seek(newProgress / duration)
                }
            case .view(.didTapGoForwards):
                let newProgress = min(state.audioPlayerState.duration.seconds, state.audioPlayerState.progress.seconds + 10)
                let duration = state.audioPlayerState.duration.seconds
                state.audioPlayerState.progress = .init(seconds: newProgress, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                
                return .run { _ in
                    await audioPlayerClient.seek(newProgress / duration)
                }
            case let .view(.didFinishedSeekingTo(progress)):
                let duration = state.audioPlayerState.duration.seconds
                
                state.audioPlayerState.progress = .init(seconds: progress, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                
                return .run { _ in
                    await audioPlayerClient.pause()
                    
                    try await withTaskCancellation(id: CancellableID.debounce, cancelInFlight: true) {
                        try await self.clock.sleep(for: .milliseconds(500))
                        
                        await audioPlayerClient.seek(progress / duration)
                        await audioPlayerClient.play()
                    }
                }
            case .view(.didTapGoToNext):
                let nextIndex = state.currentChapterIndex + 1
                
                guard state.chapterCount > nextIndex else {
                    return .none
                }
                
                guard let nextChapter = state.audiobook.value?.chapters[nextIndex] else {
                    return .none
                }
                
                let newProgress = nextChapter.startsAt + 0.1
                
                let duration = state.audioPlayerState.duration.seconds
                state.audioPlayerState.progress = .init(seconds: newProgress, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                
                return .run { _ in
                    await audioPlayerClient.seek(newProgress / duration)
                    await audioPlayerClient.play()
                }
                
            case .view(.didTapGoToPrevious):
                let previousIndex = state.currentChapterIndex - 1
                
                guard previousIndex >= 0 else {
                    return .none
                }
                
                guard let previousChapter = state.audiobook.value?.chapters[previousIndex] else {
                    return .none
                }
                
                let newProgress = previousChapter.startsAt + 0.1
                let duration = state.audioPlayerState.duration.seconds
                state.audioPlayerState.progress = .init(seconds: newProgress, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
                
                return .run { _ in
                    await audioPlayerClient.seek(newProgress / duration)
                    await audioPlayerClient.play()
                }
            case let .view(.didSelectRate(rate)):
                state.audioPlayerState.rate = rate
                return .run { _ in
                    await audioPlayerClient.setRate(rate)
                }
            case let .internal(.status(status)):
                state.audioPlayerState.status = status
                return .none
            case let .internal(.timeControlStatus(status)):
                state.audioPlayerState.timeControlStatus = status
                return .none
            case let .internal(.progress(progress)):
                state.audioPlayerState.progress = progress
                return .none
            case let .internal(.duration(duration)):
                state.audioPlayerState.duration = duration
                return .none
            case let .internal(.playbackBufferEmpty(empty)):
                state.audioPlayerState.isPlaybackBufferEmpty = empty
                return .none
            case let .internal(.playbackBufferFull(full)):
                state.audioPlayerState.isPlaybackBufferFull = full
                return .none
            case let .internal(.playbackLikelyToKeepUp(keepUp)):
                state.audioPlayerState.isPlaybackLikelyToKeepUp = keepUp
                return .none
            default :
                return .none
            }
        }
    }
}
