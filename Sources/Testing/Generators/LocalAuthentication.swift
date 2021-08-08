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
            if #available(macOS 10.11, *) {
                return Gen.fromElements(of: [.appCancel, .authenticationFailed])
            } else {
                return Gen.fromElements(of: [.authenticationFailed])
            }
        }
    }
    
}

#if os(iOS) || os(macOS)

@available(iOS 11.0, macOS 10.13.2, *)
extension LABiometryType: Arbitrary {
    
    public static var arbitrary: Gen<LABiometryType> {
        if #available(iOS 11.2, macOS 10.15, *) {
            return Gen.fromElements(of: [.none, .touchID, .faceID])
        } else {
            return Gen.fromElements(of: [.touchID])
        }
    }
    
}

#endif

#endif
