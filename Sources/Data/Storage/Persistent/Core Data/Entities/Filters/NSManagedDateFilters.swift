#if canImport(Foundation) && canImport(Combine)

import Foundation
import CoreData

// MARK: Date?

public func == <Root: NSManagedObject>(lhs: KeyPath<Root, Date?>, rhs: Date?) -> KeyPathFilter<Root, Date?> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == %@", rhs as NSDate))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == nil"))
    }
}

public func != <Root: NSManagedObject>(lhs: KeyPath<Root, Date?>, rhs: Date?) -> KeyPathFilter<Root, Date?> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != %@", rhs as NSDate))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != nil"))
    }
}

public func < <Root: NSManagedObject>(lhs: KeyPath<Root, Date?>, rhs: Date) -> KeyPathFilter<Root, Date?> {
    return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) < %@", rhs as NSDate))
}

public func <= <Root: NSManagedObject>(lhs: KeyPath<Root, Date?>, rhs: Date) -> KeyPathFilter<Root, Date?> {
    return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) <= %@", rhs as NSDate))
}

public func > <Root: NSManagedObject>(lhs: KeyPath<Root, Date?>, rhs: Date) -> KeyPathFilter<Root, Date?> {
    return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) > %@", rhs as NSDate))
}

public func >= <Root: NSManagedObject>(lhs: KeyPath<Root, Date?>, rhs: Date) -> KeyPathFilter<Root, Date?> {
    return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) >= %@", rhs as NSDate))
}

// MARK: Date

public func == <Root: NSManagedObject>(lhs: KeyPath<Root, Date>, rhs: Date?) -> KeyPathFilter<Root, Date> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == %@", rhs as NSDate))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == nil"))
    }
}

public func != <Root: NSManagedObject>(lhs: KeyPath<Root, Date>, rhs: Date?) -> KeyPathFilter<Root, Date> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != %@", rhs as NSDate))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != nil"))
    }
}

public func < <Root: NSManagedObject>(lhs: KeyPath<Root, Date>, rhs: Date) -> KeyPathFilter<Root, Date> {
    return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) < %@", rhs as NSDate))
}

public func <= <Root: NSManagedObject>(lhs: KeyPath<Root, Date>, rhs: Date) -> KeyPathFilter<Root, Date> {
    return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) <= %@", rhs as NSDate))
}

public func > <Root: NSManagedObject>(lhs: KeyPath<Root, Date>, rhs: Date) -> KeyPathFilter<Root, Date> {
    return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) > %@", rhs as NSDate))
}

public func >= <Root: NSManagedObject>(lhs: KeyPath<Root, Date>, rhs: Date) -> KeyPathFilter<Root, Date> {
    return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) >= %@", rhs as NSDate))
}

#endif
