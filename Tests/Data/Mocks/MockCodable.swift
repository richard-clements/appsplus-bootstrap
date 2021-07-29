#if canImport(SwiftCheck)

import SwiftCheck

struct MockCodable: Codable, Equatable, Arbitrary {
    let value: String
    
    public static var arbitrary: Gen<MockCodable> {
        String.arbitrary.map { MockCodable(value: $0) }
    }
}

#endif
