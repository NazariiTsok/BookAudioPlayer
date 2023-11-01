import SwiftUI

public enum PlayerRate: CaseIterable {
    
    case x0_5
    case x0_75
    case x1
    case x1_5
    case x2
    
    public var value: Float {
        switch self {
        case .x0_5:
            return 0.5
        case .x0_75:
            return 0.75
        case .x1:
            return 1.0
        case .x2:
            return 2.0
        case .x1_5:
            return 1.5
        }
    }
}

