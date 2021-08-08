#if canImport(Foundation) && canImport(SwiftCheck)

import Foundation
import SwiftCheck

extension Date: Arbitrary {
    
    public static var arbitrary: Gen<Date> {
        generator()
    }
    
    public static func generator(from startDate: Date? = nil, to endDate: Date? = nil) -> Gen<Date> {
        if let startDate = startDate?.timeIntervalSince1970, let endDate = endDate?.timeIntervalSince1970 {
            assert(startDate < endDate)
            return Gen.fromElements(in: startDate...endDate)
                .map { Date(timeIntervalSince1970: $0) }
        } else if let startDate = startDate?.timeIntervalSince1970 {
            return Gen.fromElements(in: startDate...Date.distantFuture.timeIntervalSince1970)
                .map { Date(timeIntervalSince1970: $0) }
        } else if let endDate = endDate?.timeIntervalSince1970 {
            return Gen.fromElements(in: Date.distantPast.timeIntervalSince1970...endDate)
                .map { Date(timeIntervalSince1970: $0) }
        } else {
            return Gen.fromElements(in: Date.distantPast.timeIntervalSince1970...Date.distantFuture.timeIntervalSince1970)
                .map { Date(timeIntervalSince1970: $0) }
        }
    }
    
}

#endif
