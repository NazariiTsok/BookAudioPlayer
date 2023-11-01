import SwiftUI
import ComposableArchitecture

public struct TextBookFeatureView: View {

    let store: StoreOf<TextBookFeature>
    
    public init(store: StoreOf<TextBookFeature>) {
        self.store = store
    }

   public var body: some View {
        Group {
            Text("TextBook Feature!")
        }
    }

}
