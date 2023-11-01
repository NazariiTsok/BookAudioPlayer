import SwiftUI
import ComposableArchitecture
import StoreKit
import SharedFeature

public struct SubscriptionFeatureView: View {
    let store: StoreOf<SubscriptionFeature>
    
    public init(store: StoreOf<SubscriptionFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            GeometryReader { proxy in
                Group {
                    VStack(spacing: 30) {
                        VStack(spacing: 16) {
                            Text("Unlock learning")
                                .font(.system(size: 35, weight: .bold))
                                .foregroundColor(.black)
                            
                            Text("Grow on the go by listening and reading the world's best ideas")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            switch viewStore.state {
                            case .loading:
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            case .failure:
                                Text("Account does not have enough funds")
                                    .font(.system(size: 18, weight: .semibold))
                                    .lineLimit(1)
                            case let .available(product, _, _):
                                VStack(spacing: 8) {
                                    AsyncButton {
                                        await viewStore.send(.paymentButtonTapped).finish()
                                    } label: {
                                        Text("Start Listening • \(product.displayPrice)")
                                            .font(.system(size: 18, weight: .semibold))
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.vertical, 16)
                        .contentShape(Rectangle())
                        .foregroundStyle(.white)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .padding(.bottom, proxy.safeAreaInsets.bottom)
                        .padding(.bottom)
                        
                    }
                    .padding(.horizontal)
                    .frame(
                        height: proxy.size.height * 0.6,
                        alignment: .bottom
                    )
                    .background(
                        LinearGradient(
                            gradient: Gradient(stops: [
                                .init(color: .mainColor, location: 0),
                                .init(color: .clear, location: 1),
                                
                            ]),
                            startPoint:  UnitPoint(x: 0.5, y: 0.35),
                            endPoint: .top)
                    )
                }
                .frame(
                    maxWidth : .infinity,
                    maxHeight: .infinity,
                    alignment: .bottom
                )
            }
            .task {
                await store.send(.loadSubscription).finish()
            }
        }
    }
}

struct SubscriptionFeatureView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionFeatureView(store: .init(initialState: SubscriptionFeature.State(), reducer: {
            SubscriptionFeature()
        }))
    }
}

