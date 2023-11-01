
import Foundation

public enum PlayerType: CaseIterable {
    case audioBook
    case textBook
    
    public var imageName: String {
        switch self {
        case .audioBook:
            return "headphones"
        case .textBook:
            return "list.dash"
        }
    }
}
