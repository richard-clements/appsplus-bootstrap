#if canImport(UIKit)
import UIKit

extension CGFloat {
    public enum Margin {
        case xxSmall
        case xSmall
        case small
        case medium
        case large
        case xLarge
        case xxLarge
    }
    
    public static func margin(_ x: Margin) -> CGFloat {
        switch x {
        case .xxSmall:
            return 2
        case .xSmall:
            return 4
        case .small:
            return 8
        case .medium:
            return 16
        case .large:
            return 32
        case .xLarge:
            return 64
        case .xxLarge:
            return 128
        }
    }
}
#endif
