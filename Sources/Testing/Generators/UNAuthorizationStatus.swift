#if canImport(Foundation) && canImport(UserNotifications) && canImport(SwiftCheck)

import Foundation
import SwiftCheck
import UserNotifications

@available(iOS 10.0, macOS 10.14, tvOS 10.0, watchOS 3.0, *)
extension UNAuthorizationStatus: Arbitrary {
    
    public static var arbitrary: Gen<UNAuthorizationStatus> {
        Gen.fromElements(of: [.authorized, .denied, .notDetermined])
    }
    
}

#endif
