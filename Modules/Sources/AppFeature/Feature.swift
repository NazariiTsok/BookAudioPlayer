

import Foundation
import SwiftUI
import ComposableArchitecture
import BookFeature

public struct AppFeature: Reducer{
    public struct State: Equatable {
        public var appDelegate: AppDelegateFeature.State
        public var book:BookFeature.State
        
        public init(
            appDelegate: AppDelegateFeature.State = .init(),
            book: BookFeature.State = .init(book: .preview)
        ) {
            self.book = book
            self.appDelegate = appDelegate
        }
    }
    
    public enum Action: Equatable {
        case book(BookFeature.Action)
        case appDelegate(AppDelegateFeature.Action)
    }
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        Reduce { state , action in
            switch action {
            default :
                return .none
            }
        }
        
        Scope(state: \.appDelegate, action: /Action.appDelegate) {
            AppDelegateFeature()
        }
        
        Scope(state: \.book, action: /Action.book) {
            BookFeature()
        }
    }
}
