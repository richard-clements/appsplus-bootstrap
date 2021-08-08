#if canImport(Foundation) && canImport(SwiftCheck)

import Foundation
import SwiftCheck

public struct ArbitraryPair<S, T> {
    let first: S
    let second: T
}

extension ArbitraryPair {
    public static func generator(firstGenerator: Gen<S>, secondGivenFirst: @escaping (S) -> Gen<T>) -> Gen<ArbitraryPair> {
        Gen.compose {
            let firstValue = $0.generate(using: firstGenerator)
            return ArbitraryPair.init(first: firstValue, second: $0.generate(using: secondGivenFirst(firstValue)))
        }
    }
}

extension ArbitraryPair: Arbitrary where S: Arbitrary, T: Arbitrary {
    
    public static var arbitrary: Gen<Self> {
        generator(firstGenerator: S.arbitrary) { _ in
            T.arbitrary
        }
    }
    
}

#endif
