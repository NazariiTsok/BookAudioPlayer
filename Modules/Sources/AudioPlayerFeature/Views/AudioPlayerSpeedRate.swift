
import SwiftUI
import SharedFeature

public struct AudioPlayerSpeedRate: View {
    
    @Binding var rate: Float
    
    let values: [Float]
    
    public var body: some View {
        Menu {
            ForEach(values, id: \.self) { value in
                Button(action: {
                    rate = value
                }) {
                    HStack {
                        Text(String(format: "%.1f", value) + "x").tag(value)
                        
                        if rate == value {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Text("Speed \(Text(String(format: "%.1f", rate) + "x"))")
                .font(.system(size: 14, weight: .bold))
                .padding(10)
                .background(.regularMaterial)
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        }
    }
}


struct AudioPlayerSpeedRate_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerSpeedRate(rate: .constant(1.0), values: [0.25, 0.50, 0.75, 1.0, 1.25, 1.50, 1.75, 2.0])
    }
}
