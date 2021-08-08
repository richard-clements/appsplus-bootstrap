#if canImport(Foundation) && canImport(SwiftCheck)

import Foundation
import SwiftCheck

extension Gen {
    
    public func proliferate(withSizeInRange range: ClosedRange<Int>) -> Gen<[A]> {
        Gen<Int>
            .fromElements(in: range)
            .flatMap { proliferate(withSize: $0) }
    }
    
}

#endif
