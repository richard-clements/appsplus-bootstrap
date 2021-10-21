#if canImport(UIKit)
import UIKit

extension CGFloat {
    enum Margin {
        case xSmall
        case small
        case medium
        case large
    }
    
    static func margin(_ x: Margin) -> CGFloat {
        switch x {
        case .xSmall:
            return 5
        case .small:
            return 10
        case .medium:
            return 20
        case .large:
            return 30
        }
    }
}
#endif
