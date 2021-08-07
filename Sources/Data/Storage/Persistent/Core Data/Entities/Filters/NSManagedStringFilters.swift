#if canImport(Foundation) && canImport(Combine)

import Foundation
import CoreData

// MARK: String?

public func == <Root: NSManagedObject>(lhs: KeyPath<Root, String?>, rhs: String?) -> KeyPathFilter<Root, String?> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == %@", rhs))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == nil"))
    }
}

public func != <Root: NSManagedObject>(lhs: KeyPath<Root, String?>, rhs: String?) -> KeyPathFilter<Root, String?> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != %@", rhs))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != nil"))
    }
}

// MARK: String

public func == <Root: NSManagedObject>(lhs: KeyPath<Root, String>, rhs: String?) -> KeyPathFilter<Root, String> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == %@", rhs))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == nil"))
    }
}

public func != <Root: NSManagedObject>(lhs: KeyPath<Root, String>, rhs: String?) -> KeyPathFilter<Root, String> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != %@", rhs))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != nil"))
    }
}

#endif
