
import SwiftUI

public struct AudioPlayerSlider: View {
    
    var progress: Binding<Double>
    var range: ClosedRange<Double>
    
    public init(
        progress: Binding<Double>,
        range: ClosedRange<Double>
    ) {
        self.progress = progress
        self.range = range
        
        let thumbImage = UIImage(systemName: "circle.fill")
        UISlider.appearance().setThumbImage(thumbImage, for: .normal)
    }
    
    private let dateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    var minimumLabelValue : Double {
        return self.progress.wrappedValue - self.range.lowerBound
    }
    
    var maximumLabelValue: Double {
        return self.range.upperBound - self.range.lowerBound
    }
    
    
    public var body: some View {
        Slider(value: progress, in: self.range) {
                Text("Track Slider")
            } minimumValueLabel: {
                Text(dateComponentsFormatter.string(from: TimeInterval(minimumLabelValue)) ?? "00:00")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.secondaryTextColor)
            } maximumValueLabel: {
                Text(dateComponentsFormatter.string(from: TimeInterval(maximumLabelValue)) ?? "--:--")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(.secondaryTextColor)
            }
    }
}


struct AudioPlayerSlider_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerSlider(progress: .constant(110.0), range: 0.0...123)
            .padding(.all)
    }
}



