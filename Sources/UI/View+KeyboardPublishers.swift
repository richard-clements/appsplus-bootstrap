#if canImport(SwiftUI)
import SwiftUI

extension View {
    
    public func onNotification(_ notificationName: Notification.Name, perform action: @escaping () -> Void) -> some View {
        onReceive(NotificationCenter.default.publisher(for: notificationName)) { _ in
            action()
        }
    }
    
    public func keyboardWillShowNotification(perform action: @escaping () -> Void) -> some View {
        onNotification(UIResponder.keyboardWillShowNotification, perform: action)
    }
    
    public func keyboardWillHideNotification(perform action: @escaping () -> Void) -> some View {
        onNotification(UIResponder.keyboardWillHideNotification, perform: action)
    }
    
}
#endif
