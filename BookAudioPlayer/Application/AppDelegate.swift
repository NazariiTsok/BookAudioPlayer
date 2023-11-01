import Foundation
import ComposableArchitecture
import UIKit
import AppFeature

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    let store: StoreOf<AppFeature> = {
        return Store(
            initialState: AppFeature.State(),
            reducer: {
                AppFeature()
            }
        )
    }()
    
    lazy var viewStore = ViewStore(store, observe: { $0 })
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        self.viewStore.send(.appDelegate(.didFinishLaunching))
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        self.viewStore.send(.appDelegate(.willResignActive))
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        self.viewStore.send(.appDelegate(.willEnterForeground(application)))
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.viewStore.send(.appDelegate(.didEnterBackground(application)))
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.viewStore.send(.appDelegate(.didBecomeActive))
    }
}
