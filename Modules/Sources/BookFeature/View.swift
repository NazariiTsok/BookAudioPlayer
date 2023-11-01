import SwiftUI
import ComposableArchitecture
import AudioPlayerFeature
import TextBookFeature
import SubscriptionFeature
import SharedFeature

public struct BookFeatureView: View {
    
    let store: StoreOf<BookFeature>
    @ObservedObject var viewStore: ViewStore<ViewState, BookFeature.Action>
    
    struct ViewState: Equatable {
        let hasPremium: Bool
        
        init(state: BookFeature.State) {
            self.hasPremium = state.hasPremium
        }
    }
    
    public init(
        store: StoreOf<BookFeature>
    ) {
        self.store = store
        self.viewStore = ViewStore(self.store, observe: ViewState.init)
    }
    
    public var body: some View {
        Group {
            SwitchStore(self.store.scope(state: \.content, action: { $0 })) { state in
                switch state {
                case .audioBook:
                    CaseLet(/BookFeature.State.ContentState.audioBook, action: BookFeature.Action.audioBook) {
                        AudioPlayerFeatureView(store: $0)
                    }
                case .textBook:
                    CaseLet(/BookFeature.State.ContentState.textBook, action: BookFeature.Action.textBook) {
                        TextBookFeatureView(store: $0)
                    }
                }
            }
        }
        .onAppear {
            viewStore.send(.view(.didAppear))
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .ignoresSafeArea(.all)
        .background(Color.mainColor)
        .overlay(alignment: .bottom) {
            BookContentTypePicker(type: .constant(.audioBook))
        }
        .overlay(alignment: .bottom) {
            if !viewStore.hasPremium {
                SubscriptionFeatureView(
                    store: store.scope(
                        state: \.subscription,
                        action: { .subscription($0) }
                    )
                )
            }
        }
    }
}

