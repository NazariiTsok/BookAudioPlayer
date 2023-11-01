
import SwiftUI

public struct AudioPlayerPreview: View {
    
    var previewData: Data?
    var proxy: GeometryProxy
    
    public var body: some View {
        Group {
            if let data = previewData {
                Image(data: data)?
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }else {
                ProgressView()
            }
        }
        .frame(
            width: proxy.size.width * 0.55,
            height: proxy.size.height * 0.4,
            alignment: .center
        )
        .background(.secondary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .clipShape(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
        )

    }
}
