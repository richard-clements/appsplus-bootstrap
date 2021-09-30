#if canImport(Foundation) && canImport(LocalAuthentication) && canImport(SwiftCheck)

import Foundation
import SwiftCheck
import LocalAuthentication

@available(tvOS 10.0, *)
extension LAError.Code: Arbitrary {
    
    public static var arbitrary: Gen<LAError.Code> {
        if #available(iOS 11.0, tvOS 11.0, macOS 10.13, *) {
            return Gen.fromElements(of: [.appCancel, .authenticationFailed, .biometryLockout, .biometryNotAvailable, .biometryNotEnrolled])
        } else {
            return Gen.fromElements(of: [.appCancel, .authenticationFailed])
        }
    }
    
}

#if os(iOS) || os(macOS)

@available(iOS 11.0, macOS 10.13.2, *)
extension LABiometryType: Arbitrary {
    
    public static var arbitrary: Gen<LABiometryType> {
        return Gen.fromElements(of: [.none, .touchID, .faceID])
    }
    
}

#endif

#endif
