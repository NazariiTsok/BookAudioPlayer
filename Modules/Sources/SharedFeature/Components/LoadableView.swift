
import ComposableArchitecture
import Foundation
import SwiftUI

public struct LoadableView<T, Loaded: View, Failed: View, Loading: View, Initial: View>: View {
    let loadable: Loadable<T>
    
    let initialView: () -> Initial
    let loadingView: () -> Loading
    let loadedView: (T) -> Loaded
    let failedView: (Error) -> Failed
   
    public init(
        loadable: Loadable<T>,
        @ViewBuilder initialView: @escaping () -> Initial,
        @ViewBuilder loadingView: @escaping () -> Loading,
        @ViewBuilder loadedView: @escaping (T) -> Loaded,
        @ViewBuilder failedView: @escaping (Error) -> Failed
       
    ) {
        self.loadable = loadable
        self.initialView = initialView
        self.loadingView = loadingView
        self.loadedView = loadedView
        self.failedView = failedView
    }

    public var body: some View {
        switch loadable {
        case .initial:
            initialView()
        case .loading:
            loadingView()
        case let .loaded(t):
            loadedView(t)
        case let .failed(e):
            failedView(e)
        }
    }
}

public extension LoadableView {
    init(
        loadable: Loadable<T>,
        @ViewBuilder loadedView: @escaping (T) -> Loaded
    ) where Loading == EmptyView, Failed == EmptyView, Initial == EmptyView {
        self.init(
            loadable: loadable,
            initialView: { EmptyView() },
            loadingView: { EmptyView() },
            loadedView: loadedView,
            failedView: { _ in EmptyView() }
        )
    }

    init(
        loadable: Loadable<T>,
        @ViewBuilder loadedView: @escaping (T) -> Loaded,
        @ViewBuilder failedView: @escaping (Error) -> Failed
    ) where Loading == EmptyView, Initial == EmptyView {
        self.init(
            loadable: loadable,
            initialView: {
                EmptyView()
            },
            loadingView: {
                EmptyView()
            },
            loadedView: loadedView,
            failedView: failedView
        )
    }

    init(
        loadable: Loadable<T>,
        @ViewBuilder loadedView: @escaping (T) -> Loaded,
        @ViewBuilder failedView: @escaping (Error) -> Failed,
        @ViewBuilder loadingView: @escaping () -> Loading
    ) where Loading == Initial {
        self.init(
            loadable: loadable,
            initialView: loadingView,
            loadingView: loadingView,
            loadedView: loadedView,
            failedView: failedView
        )
    }
}

