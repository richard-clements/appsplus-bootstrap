#if canImport(Foundation) && canImport(Combine)

import Foundation
import CoreData

// MARK: URL?

public func == <Root: NSManagedObject>(lhs: KeyPath<Root, URL?>, rhs: URL?) -> KeyPathFilter<Root, URL?> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == %@", rhs.absoluteString))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == nil"))
    }
}

public func != <Root: NSManagedObject>(lhs: KeyPath<Root, URL?>, rhs: URL?) -> KeyPathFilter<Root, URL?> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != %@", rhs.absoluteString))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != nil"))
    }
}

// MARK: URL

public func == <Root: NSManagedObject>(lhs: KeyPath<Root, URL>, rhs: URL?) -> KeyPathFilter<Root, URL> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == %@", rhs.absoluteString))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == nil"))
    }
}

public func != <Root: NSManagedObject>(lhs: KeyPath<Root, URL>, rhs: URL?) -> KeyPathFilter<Root, URL> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != %@", rhs.absoluteString))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != nil"))
    }
}

#endif
