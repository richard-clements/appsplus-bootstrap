#if canImport(UIKit) && (os(iOS) || os(tvOS) || os(macOS))

import UIKit

@available(iOS 10.0, tvOS 10.0, *)
extension UIColor {
    
    func asImage(_ size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { context in
            setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
    
}

#endif
