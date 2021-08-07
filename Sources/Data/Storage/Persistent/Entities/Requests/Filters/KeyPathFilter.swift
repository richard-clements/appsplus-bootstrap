#if canImport(Foundation)

import Foundation

public struct KeyPathFilter<Root, Value> {
    let predicate: NSPredicate
}

#endif
