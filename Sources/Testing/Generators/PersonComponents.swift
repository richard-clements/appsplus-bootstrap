#if canImport(Foundation)
import Foundation
import SwiftCheck

extension PersonNameComponents: Arbitrary {
    
    public static var arbitrary: Gen<PersonNameComponents> {
        Gen.compose { composer in
            var components = PersonNameComponents()
            components.familyName = composer.generate()
            components.givenName = composer.generate()
            return components
        }
    }
}
#endif
