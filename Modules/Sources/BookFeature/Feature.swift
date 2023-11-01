

import Foundation
import SwiftUI
import ComposableArchitecture
import SharedFeature
import AudioPlayerFeature
import TextBookFeature
import SubscriptionFeature
import AudioBookClient

public struct BookFeature: Reducer{
    public struct State: Equatable {
        
        public var book: Book
       
        public var subscription: SubscriptionFeature.State
        public var hasPremium: Bool
        
        public var content: BookFeature.State.ContentState
        
        public enum ContentState: Equatable {
            case audioBook(AudioPlayerFeature.State)
            case textBook(TextBookFeature.State)
        }
        
        public init(
            book: Book,
            subscription: SubscriptionFeature.State = .init(),
            hasPremium: Bool? = nil
        ) {
            
            @Dependency(\.premiumClient) var premiumClient
            self.hasPremium = hasPremium ?? premiumClient.isCurrentlyPremium
            
            self.book = book
            self.subscription = subscription
            self.content = .audioBook(.init(audioBookId: book.audioBookId))
        }
    }
    
    public enum Action: Equatable {
        
        public enum ViewAction: Equatable{
            case didAppear
            case didSelectContentState(BookFeature.State.ContentState)
        }
        
        public enum InternalAction: Equatable {
            case listen
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        
        case audioBook(AudioPlayerFeature.Action)
        case textBook(TextBookFeature.Action)
        
        case subscription(SubscriptionFeature.Action)
        
        case subscribeToPremiumUpdates
        case subscriptionPremiumChanged(Bool)
        case subscribeToPremiumFailed
    }
    
    enum CancellableID: Hashable {
        case initialize
    }
    
    @Dependency(\.premiumClient) var premiumService
    @Dependency(\.audioBookClient) var audioBookClient
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { state , action in
            switch action {
            case .view(.didAppear):
                return .run { send in
                    await withTaskCancellation(id: CancellableID.initialize) {
                        await withTaskGroup(of: Void.self) { group in
                            
                            group.addTask {
                                for await value in premiumService.isPremium.removeDuplicates().values {
                                    await send(.subscriptionPremiumChanged(value))
                                }
                            }
                        }
                    }
                }
            case let.view(.didSelectContentState(value)):
                state.content = value
                
                switch state.content {
                case .audioBook:
                    state.content = .audioBook(
                        AudioPlayerFeature.State(audioBookId: state.book.audioBookId)
                    )
                case .textBook:
                    state.content = .textBook(
                        TextBookFeature.State(readBookId: state.book.readBookId)
                    )
                }
                return .none
            case let .subscriptionPremiumChanged(value):
                state.hasPremium = value
                
                return .none
            case .subscribeToPremiumFailed:
                return .none
            default :
                return .none
            }
        }
        
        Scope(state: \.content, action: .self) {
            Scope(state: /State.ContentState.audioBook, action: /Action.audioBook) {
                AudioPlayerFeature()
            }
            
            Scope(state: /State.ContentState.textBook, action: /Action.textBook) {
                TextBookFeature()
            }
        }
        
        Scope(state: \.subscription, action: /Action.subscription) {
            SubscriptionFeature()
        }
    }
}
