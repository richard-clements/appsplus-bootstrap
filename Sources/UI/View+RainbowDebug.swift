#if canImport(SwiftUI)
import SwiftUI

#if DEBUG
@available(iOS 13.0, tvOS 13.0, *)
private let rainbowDebugColors = [Color.purple, Color.blue, Color.green, Color.yellow, Color.orange, Color.red]

extension View {
    public func rainbowDebug() -> some View {
        self.background(rainbowDebugColors.randomElement()!)
    }
}
#endif
#endif
