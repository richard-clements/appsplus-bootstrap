#if canImport(Foundation)

import Foundation

public struct MockCodable: Codable, Equatable {
    let value: String
}

#endif
