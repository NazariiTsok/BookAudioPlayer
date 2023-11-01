
import SwiftUI
import ComposableArchitecture

public struct AudioPlayerControlAction: View {
    
    @ObservedObject var viewStore: ViewStore<AudioPlayerFeature.State, AudioPlayerFeature.Action>
    
    public var body: some View {
        Group {
            HStack(alignment: .center, spacing: 30) {
                Button {
                    viewStore.send(.view(.didTapGoToPrevious))
                } label: {
                    Image(systemName: "backward.end.fill")
                        .font(.title.weight(.semibold))
                        .contentShape(Rectangle())
                }
                .disabled(!viewStore.hasPreviousChapter)
                
                Button {
                    viewStore.send(.view(.didTapGoBackwards))
                } label: {
                    Image(systemName: "gobackward.5")
                        .font(.title.weight(.semibold))
                        .contentShape(Rectangle())
                }
                
                Group {
                    if viewStore.isBuffering {
                        ProgressView()
                            .scaleEffect(1.25)
                    } else {
                        Button {
                            viewStore.send(.view(.didTogglePlayButton))
                        } label: {
                            Image(systemName: viewStore.isPlaying ? "pause.fill" : "play.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .font(.largeTitle)
                                .frame(width: 35, height: 35, alignment: .center)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(width: 35, height: 35, alignment: .center)
                
                Button {
                    viewStore.send(.view(.didTapGoForwards))
                } label: {
                    Image(systemName: "goforward.10")
                        .font(.title.weight(.semibold))
                        .contentShape(Rectangle())
                }
                
                Button {
                    viewStore.send(.view(.didTapGoToNext))
                } label: {
                    Image(systemName: "forward.end.fill")
                        .font(.title.weight(.semibold))
                        .contentShape(Rectangle())
                }
                .disabled(!viewStore.hasNextChapter)
            }
            .foregroundColor(.black)
            .buttonStyle(.plain)
        }
    }
}
