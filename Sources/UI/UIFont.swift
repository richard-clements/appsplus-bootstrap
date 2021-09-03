#if canImport(UIKit)

import UIKit

@available(iOS 13.0, tvOS 13.0, *)
extension UIFont.TextStyle {
    public static let smallBody = UIFont.TextStyle(rawValue: "SmallBody")
    public static let button1 = UIFont.TextStyle(rawValue: "Button1")
    public static let button2 = UIFont.TextStyle(rawValue: "Button2")
}

@available(iOS 13.0, tvOS 13.0, *)
extension UIFont {
    
    public static var appFontProvider: (UIFont.TextStyle) -> UIFont = UIFont.preferredFont
    
}

#endif
