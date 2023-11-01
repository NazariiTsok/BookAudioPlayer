

import Foundation
import SwiftUI
import ComposableArchitecture
import SharedFeature

public struct TextBookFeature: Reducer{
    public struct State: Equatable {
        
        public var readBookId: String
        
        public init(readBookId: String) {
            self.readBookId = readBookId
        }
    }
    
    public enum Action: Equatable {
        
    }
    
    public init() {}
    
    public var body: some Reducer<State, Action> {
        EmptyReducer()
        
    }
}
