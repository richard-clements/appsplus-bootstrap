#if canImport(UIKit) && (os(iOS) || os(tvOS) || os(macOS))

import UIKit

extension UIStackView {
    
    public func addArrangedSubviews(_ views: UIView...) {
        views.forEach { addArrangedSubview($0) }
    }
    
    public func setCustomSpacing(_ spacing: CGFloat, after views: UIView...) {
        views.forEach { setCustomSpacing(spacing, after: $0) }
    }
    
}

#endif

