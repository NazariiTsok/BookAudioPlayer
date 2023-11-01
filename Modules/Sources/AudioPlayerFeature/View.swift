import SwiftUI
import ComposableArchitecture
import SharedFeature

public struct AudioPlayerFeatureView: View {
    
    let store: StoreOf<AudioPlayerFeature>
    
    public init(
        store: StoreOf<AudioPlayerFeature>
    ) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            LoadableView(loadable: viewStore.audiobook) { audiobook in
                GeometryReader { proxy in
                    Group {
                        VStack(spacing : .zero) {
                            AudioPlayerPreview(
                                previewData: viewStore.artworkPreview,
                                proxy: proxy
                            )
                            .padding(.top, proxy.safeAreaInsets.top)
                            .padding(.top, 90)
                            
                            AudioPlayerDescription(
                                currentTitle: viewStore.currentChapterTitle,
                                currentIndex: viewStore.currentChapterIndex,
                                totalIndex: viewStore.chapterCount
                            )
                            .padding([.horizontal, .top], 30)
                            
                            
                            AudioPlayerSlider(
                                progress: viewStore.binding(
                                    get: \.progress,
                                    send: { .view(.didFinishedSeekingTo($0))}
                                ),
                                range: viewStore.currentChapter.startsAt...viewStore.currentChapter.endsAt
                            )
                            .padding([.leading, .trailing])
                            .disabled(!viewStore.isSliderEnabled)

                            AudioPlayerSpeedRate(
                                rate: viewStore.binding(
                                    get: \.rate,
                                    send: { .view(.didSelectRate($0)) }
                                ),
                                values: viewStore.rateValues
                            )
                            .padding(.top)

                            AudioPlayerControlAction(viewStore: viewStore)
                                .padding(.vertical, 60)
                            
                            Spacer()
                            
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .top
                    )
                    .ignoresSafeArea(.all)
                    .background(Color.mainColor)
                }
            } failedView: { _ in
                //MARK: We can handle error caption view when smth happen with loading file
                Text("Failed to load audiobook content file")
            } loadingView: {
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.regular)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .task {
            await store.send(.view(.didAppear)).finish()
        }
    }
    
}
