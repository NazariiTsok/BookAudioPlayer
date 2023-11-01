import ComposableArchitecture
import Foundation
import SwiftUI
import StoreKitClient

public struct AppDelegateFeature: Reducer {
    
    public struct State: Equatable {
        public init() {}
      }
    
    public enum Action: Equatable {
        case didFinishLaunching
        
        case willResignActive
        case willEnterForeground(_ application: UIApplication)
        case didEnterBackground(_ application: UIApplication)
        case didBecomeActive
        
        case didRegisterForRemoteNotifications(Result<Data, NSError>)
        case didChangeScenePhase(ScenePhase)
    }
    
    @Dependency(\.storeKitClient) public var storeKitClient
    
    public var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .didFinishLaunching:
                return .run { send in
                    await withThrowingTaskGroup(of: Void.self) { group in
                        group.addTask {
                            storeKitClient.observeSubscriptionStatus() 
                        }
                    }
                }
            default :
                return .none
            }
        }
    }
}
