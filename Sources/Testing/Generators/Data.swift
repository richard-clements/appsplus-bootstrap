#if canImport(Foundation)

import Foundation
import SwiftCheck

extension Data: Arbitrary {
    
    public static var arbitrary: Gen<Data> {
        UInt8.arbitrary.proliferate.map { Data($0) }
    }
}

#endif
