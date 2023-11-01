
import SwiftUI
import ComposableArchitecture
import BookFeature

public struct AppView: View {
    let store: StoreOf<AppFeature>
    
    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }
    
    public var body: some View {
        BookFeatureView(
            store: self.store.scope(
                state: \.book,
                action: AppFeature.Action.book
            )
        )
    }
}


struct AppView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(
            store: .init(
                initialState: AppFeature.State(),
                reducer: { AppFeature() }
            )
        )
    }
}
