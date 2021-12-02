#if canImport(Foundation) && canImport(SwiftCheck)

import Foundation
import SwiftCheck

extension DateInterval: Arbitrary {
    public static var arbitrary: Gen<DateInterval> {
        Gen.compose {
            let startTimeInterval = $0.generate(using: TimeInterval.arbitrary)
            let endTimeInterval = $0.generate(using: TimeInterval.arbitrary.suchThat { $0 >= startTimeInterval })
            
            return DateInterval(
                start: Date(timeIntervalSince1970: startTimeInterval),
                end: Date(timeIntervalSince1970: endTimeInterval)
            )
        }
    }
}

#endif
