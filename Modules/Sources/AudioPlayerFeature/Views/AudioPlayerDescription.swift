
import SwiftUI

public struct AudioPlayerDescription: View {
    
    var currentTitle: String
    var currentIndex: Int
    var totalIndex: Int
    
    public init(
        currentTitle: String,
        currentIndex: Int,
        totalIndex: Int
    ) {
        self.currentTitle = currentTitle
        self.currentIndex = currentIndex + 1
        self.totalIndex = totalIndex
    }
    
    public var body: some View {
        VStack(spacing: 10) {
            Text("KEY POINT \(self.currentIndex) OF \(self.totalIndex)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)
                .kerning(0.65)
                .lineLimit(1)
                
            
            VStack {
                Text(self.currentTitle)
                    .foregroundColor(.black)
                    .font(.system(size: 15, weight: .regular))
                    .lineSpacing(4)
                    .lineLimit(3)
                    .kerning(0.5)
                Spacer()
            }
            .frame(
                maxWidth: .infinity,
                alignment: .top
            )
            .frame(minHeight : .zero, maxHeight: 50)
        }
        .frame(
            maxWidth: .infinity,
            alignment: .top
        )
        .multilineTextAlignment(.center)
    }
}

struct AudioPlayerDescription_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerDescription(
            currentTitle: .init(),
            currentIndex: 2,
            totalIndex: 10
        )
    }
}
