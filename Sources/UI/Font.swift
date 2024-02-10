#if canImport(SwiftUI)

import SwiftUI

@available(iOS 13.0, tvOS 13.0, *)
extension UIFont.TextStyle {
    public static func from(_ style: UIFont.TextStyle) -> Font.TextStyle {
        switch style {
        case .largeTitle:
            return .largeTitle
        case .title1:
            return .title
        case .title2:
            return .title2
        case .title3:
            return .title3
        case .headline:
            return .headline
        case .body:
            return .body
        case .callout:
            return .callout
        case .footnote:
            return .footnote
        case .caption1:
            return .caption
        case .caption2:
            return .caption2
        default:
            return .body
        }
    }
}

@available(iOS 13.0, tvOS 13.0, *)
extension Font {
    
    public static var appFontProvider: (UIFont.TextStyle) -> Font = {
        Font.system(UIFont.TextStyle.from($0))
    }
    
}

#endif
