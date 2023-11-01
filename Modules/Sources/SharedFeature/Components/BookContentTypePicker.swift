

import Foundation
import SwiftUI

public struct BookContentTypePicker: View {
    @Binding var type: PlayerType
    
    public init(type: Binding<PlayerType>) {
        self._type = type
        
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.blue)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
    }
    
    public var body: some View {
        Picker("Choose type", selection: $type) {
            ForEach(PlayerType.allCases, id: \.self) { type in
                Image(systemName: type.imageName).tag(type.imageName)
            }
        }
        .frame(width: 120, height: 40, alignment: .center)
        .pickerStyle(.segmented)
    }
}


struct PlayerTypePickerView_Previews: PreviewProvider {
    static var previews: some View {
        BookContentTypePicker(type: .constant(.audioBook))
    }
}

extension UISegmentedControl {
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.setContentHuggingPriority(.defaultLow, for: .vertical)
    }
}
