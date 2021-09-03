#if canImport(UIKit)

import UIKit

@available(iOS 13.0, tvOS 13.0, *)
extension UIFont {
    
    public static var appFontProvider: (UIFont.TextStyle) -> UIFont = UIFont.preferredFont
    
}

#endif
