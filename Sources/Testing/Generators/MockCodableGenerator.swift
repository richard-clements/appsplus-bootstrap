#if canImport(Foundation) && canImport(SwiftCheck)

import Foundation
import SwiftCheck

extension MockCodable: Arbitrary {
    public static var arbitrary: Gen<MockCodable> {
        String.arbitrary.map { MockCodable(value: $0) }
    }
}

#endif
