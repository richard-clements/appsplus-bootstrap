#if canImport(Foundation) && canImport(Combine)

import Foundation
import CoreData

// MARK: UUID?

public func == <Root: NSManagedObject>(lhs: KeyPath<Root, UUID?>, rhs: UUID?) -> KeyPathFilter<Root, UUID?> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == %@", rhs.uuidString))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == nil"))
    }
}

public func != <Root: NSManagedObject>(lhs: KeyPath<Root, UUID?>, rhs: UUID?) -> KeyPathFilter<Root, UUID?> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != %@", rhs.uuidString))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != nil"))
    }
}

// MARK: UUID

public func == <Root: NSManagedObject>(lhs: KeyPath<Root, UUID>, rhs: UUID?) -> KeyPathFilter<Root, UUID> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == %@", rhs.uuidString))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == nil"))
    }
}

public func != <Root: NSManagedObject>(lhs: KeyPath<Root, UUID>, rhs: UUID?) -> KeyPathFilter<Root, UUID> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != %@", rhs.uuidString))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != nil"))
    }
}

#endif
