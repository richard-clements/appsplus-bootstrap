#if canImport(UIKit)

import UIKit

extension UIStackView {
    
    func addArrangedSubviews(_ views: UIView...) {
        views.forEach { addArrangedSubview($0) }
    }
    
    func setCustomSpacing(_ spacing: CGFloat, after views: UIView...) {
        views.forEach { setCustomSpacing(spacing, after: $0) }
    }
    
}

#endif

