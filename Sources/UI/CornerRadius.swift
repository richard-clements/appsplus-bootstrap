#if canImport(UIKit)
import UIKit

public enum CornerRadius: Equatable {
    case value(CGFloat)
    case percentage(CGFloat)
}

extension CornerRadius {
    
    static let `default` = CornerRadius.value(8)
}
#endif
