#if canImport(Foundation) && canImport(Combine)

import Foundation
import CoreData

extension KeyPathFilter {
    
    fileprivate init(keyPath: String, equals value: NSNumber?) {
        if let value = value {
            self.predicate = NSPredicate(format: "\(keyPath) == %@", value)
        } else {
            self.predicate = NSPredicate(format: "\(keyPath) == nil")
        }
    }
    
    fileprivate init(keyPath: String, notEquals value: NSNumber?) {
        if let value = value {
            self.predicate = NSPredicate(format: "\(keyPath) != %@", value)
        } else {
            self.predicate = NSPredicate(format: "\(keyPath) != nil")
        }
    }
    
    fileprivate init(keyPath: String, lessThan value: NSNumber) {
        self.predicate = NSPredicate(format: "\(keyPath) < %@", value)
    }
    
    fileprivate init(keyPath: String, lessThanOrEqualTo value: NSNumber) {
        self.predicate = NSPredicate(format: "\(keyPath) <= %@", value)
    }
    
    fileprivate init(keyPath: String, greaterThan value: NSNumber) {
        self.predicate = NSPredicate(format: "\(keyPath) > %@", value)
    }
    
    fileprivate init(keyPath: String, greaterThanOrEqualTo value: NSNumber) {
        self.predicate = NSPredicate(format: "\(keyPath) >= %@", value)
    }
}

// MARK: Bool

public func == <Root: NSManagedObject>(lhs: KeyPath<Root, Bool>, rhs: Bool?) -> KeyPathFilter<Root, Bool> {
    KeyPathFilter(keyPath: lhs.keyPath, equals: rhs.map(NSNumber.init))
}

public func != <Root: NSManagedObject>(lhs: KeyPath<Root, Bool>, rhs: Bool?) -> KeyPathFilter<Root, Bool> {
    KeyPathFilter(keyPath: lhs.keyPath, notEquals: rhs.map(NSNumber.init))
}

// MARK: Int16

public func == <Root: NSManagedObject>(lhs: KeyPath<Root, Int16>, rhs: Int16?) -> KeyPathFilter<Root, Int16> {
    KeyPathFilter(keyPath: lhs.keyPath, equals: rhs.map(NSNumber.init))
}

public func != <Root: NSManagedObject>(lhs: KeyPath<Root, Int16>, rhs: Int16?) -> KeyPathFilter<Root, Int16> {
    KeyPathFilter(keyPath: lhs.keyPath, notEquals: rhs.map(NSNumber.init))
}

public func < <Root: NSManagedObject>(lhs: KeyPath<Root, Int16>, rhs: Int16) -> KeyPathFilter<Root, Int16> {
    KeyPathFilter(keyPath: lhs.keyPath, lessThan: NSNumber(value: rhs))
}

public func <= <Root: NSManagedObject>(lhs: KeyPath<Root, Int16>, rhs: Int16) -> KeyPathFilter<Root, Int16> {
    KeyPathFilter(keyPath: lhs.keyPath, lessThanOrEqualTo: NSNumber(value: rhs))
}

public func > <Root: NSManagedObject>(lhs: KeyPath<Root, Int16>, rhs: Int16) -> KeyPathFilter<Root, Int16> {
    KeyPathFilter(keyPath: lhs.keyPath, greaterThan: NSNumber(value: rhs))
}

public func >= <Root: NSManagedObject>(lhs: KeyPath<Root, Int16>, rhs: Int16) -> KeyPathFilter<Root, Int16> {
    KeyPathFilter(keyPath: lhs.keyPath, greaterThanOrEqualTo: NSNumber(value: rhs))
}

// MARK: Int32

public func == <Root: NSManagedObject>(lhs: KeyPath<Root, Int32>, rhs: Int32?) -> KeyPathFilter<Root, Int32> {
    KeyPathFilter(keyPath: lhs.keyPath, equals: rhs.map(NSNumber.init))
}

public func != <Root: NSManagedObject>(lhs: KeyPath<Root, Int32>, rhs: Int32?) -> KeyPathFilter<Root, Int32> {
    KeyPathFilter(keyPath: lhs.keyPath, notEquals: rhs.map(NSNumber.init))
}

public func < <Root: NSManagedObject>(lhs: KeyPath<Root, Int32>, rhs: Int32) -> KeyPathFilter<Root, Int32> {
    KeyPathFilter(keyPath: lhs.keyPath, lessThan: NSNumber(value: rhs))
}

public func <= <Root: NSManagedObject>(lhs: KeyPath<Root, Int32>, rhs: Int32) -> KeyPathFilter<Root, Int32> {
    KeyPathFilter(keyPath: lhs.keyPath, lessThanOrEqualTo: NSNumber(value: rhs))
}

public func > <Root: NSManagedObject>(lhs: KeyPath<Root, Int32>, rhs: Int32) -> KeyPathFilter<Root, Int32> {
    KeyPathFilter(keyPath: lhs.keyPath, greaterThan: NSNumber(value: rhs))
}

public func >= <Root: NSManagedObject>(lhs: KeyPath<Root, Int32>, rhs: Int32) -> KeyPathFilter<Root, Int32> {
    KeyPathFilter(keyPath: lhs.keyPath, greaterThanOrEqualTo: NSNumber(value: rhs))
}

// MARK: Int64

public func == <Root: NSManagedObject>(lhs: KeyPath<Root, Int64>, rhs: Int64?) -> KeyPathFilter<Root, Int64> {
    KeyPathFilter(keyPath: lhs.keyPath, equals: rhs.map(NSNumber.init))
}

public func != <Root: NSManagedObject>(lhs: KeyPath<Root, Int64>, rhs: Int64?) -> KeyPathFilter<Root, Int64> {
    KeyPathFilter(keyPath: lhs.keyPath, notEquals: rhs.map(NSNumber.init))
}

public func < <Root: NSManagedObject>(lhs: KeyPath<Root, Int64>, rhs: Int64) -> KeyPathFilter<Root, Int64> {
    KeyPathFilter(keyPath: lhs.keyPath, lessThan: NSNumber(value: rhs))
}

public func <= <Root: NSManagedObject>(lhs: KeyPath<Root, Int64>, rhs: Int64) -> KeyPathFilter<Root, Int64> {
    KeyPathFilter(keyPath: lhs.keyPath, lessThanOrEqualTo: NSNumber(value: rhs))
}

public func > <Root: NSManagedObject>(lhs: KeyPath<Root, Int64>, rhs: Int64) -> KeyPathFilter<Root, Int64> {
    KeyPathFilter(keyPath: lhs.keyPath, greaterThan: NSNumber(value: rhs))
}

public func >= <Root: NSManagedObject>(lhs: KeyPath<Root, Int64>, rhs: Int64) -> KeyPathFilter<Root, Int64> {
    KeyPathFilter(keyPath: lhs.keyPath, greaterThanOrEqualTo: NSNumber(value: rhs))
}

// MARK: Double

public func == <Root: NSManagedObject>(lhs: KeyPath<Root, Double>, rhs: Double?) -> KeyPathFilter<Root, Double> {
    KeyPathFilter(keyPath: lhs.keyPath, equals: rhs.map(NSNumber.init))
}

public func != <Root: NSManagedObject>(lhs: KeyPath<Root, Double>, rhs: Double?) -> KeyPathFilter<Root, Double> {
    KeyPathFilter(keyPath: lhs.keyPath, notEquals: rhs.map(NSNumber.init))
}

public func < <Root: NSManagedObject>(lhs: KeyPath<Root, Double>, rhs: Double) -> KeyPathFilter<Root, Double> {
    KeyPathFilter(keyPath: lhs.keyPath, lessThan: NSNumber(value: rhs))
}

public func <= <Root: NSManagedObject>(lhs: KeyPath<Root, Double>, rhs: Double) -> KeyPathFilter<Root, Double> {
    KeyPathFilter(keyPath: lhs.keyPath, lessThanOrEqualTo: NSNumber(value: rhs))
}

public func > <Root: NSManagedObject>(lhs: KeyPath<Root, Double>, rhs: Double) -> KeyPathFilter<Root, Double> {
    KeyPathFilter(keyPath: lhs.keyPath, greaterThan: NSNumber(value: rhs))
}

public func >= <Root: NSManagedObject>(lhs: KeyPath<Root, Double>, rhs: Double) -> KeyPathFilter<Root, Double> {
    KeyPathFilter(keyPath: lhs.keyPath, greaterThanOrEqualTo: NSNumber(value: rhs))
}

// MARK: Float

public func == <Root: NSManagedObject>(lhs: KeyPath<Root, Float>, rhs: Float?) -> KeyPathFilter<Root, Float> {
    KeyPathFilter(keyPath: lhs.keyPath, equals: rhs.map(NSNumber.init))
}

public func != <Root: NSManagedObject>(lhs: KeyPath<Root, Float>, rhs: Float?) -> KeyPathFilter<Root, Float> {
    KeyPathFilter(keyPath: lhs.keyPath, notEquals: rhs.map(NSNumber.init))
}

public func < <Root: NSManagedObject>(lhs: KeyPath<Root, Float>, rhs: Float) -> KeyPathFilter<Root, Float> {
    KeyPathFilter(keyPath: lhs.keyPath, lessThan: NSNumber(value: rhs))
}

public func <= <Root: NSManagedObject>(lhs: KeyPath<Root, Float>, rhs: Float) -> KeyPathFilter<Root, Float> {
    KeyPathFilter(keyPath: lhs.keyPath, lessThanOrEqualTo: NSNumber(value: rhs))
}

public func > <Root: NSManagedObject>(lhs: KeyPath<Root, Float>, rhs: Float) -> KeyPathFilter<Root, Float> {
    KeyPathFilter(keyPath: lhs.keyPath, greaterThan: NSNumber(value: rhs))
}

public func >= <Root: NSManagedObject>(lhs: KeyPath<Root, Float>, rhs: Float) -> KeyPathFilter<Root, Float> {
    KeyPathFilter(keyPath: lhs.keyPath, greaterThanOrEqualTo: NSNumber(value: rhs))
}

// MARK: NSNumber?

public func == <Root: NSManagedObject>(lhs: KeyPath<Root, NSNumber?>, rhs: NSNumber?) -> KeyPathFilter<Root, NSNumber?> {
    KeyPathFilter(keyPath: lhs.keyPath, equals: rhs)
}

public func != <Root: NSManagedObject>(lhs: KeyPath<Root, NSNumber?>, rhs: NSNumber?) -> KeyPathFilter<Root, NSNumber?> {
    KeyPathFilter(keyPath: lhs.keyPath, notEquals: rhs.map(NSNumber.init))
}

public func < <Root: NSManagedObject>(lhs: KeyPath<Root, NSNumber?>, rhs: NSNumber) -> KeyPathFilter<Root, NSNumber?> {
    KeyPathFilter(keyPath: lhs.keyPath, lessThan: rhs)
}

public func <= <Root: NSManagedObject>(lhs: KeyPath<Root, NSNumber?>, rhs: NSNumber) -> KeyPathFilter<Root, NSNumber?> {
    KeyPathFilter(keyPath: lhs.keyPath, lessThanOrEqualTo: rhs)
}

public func > <Root: NSManagedObject>(lhs: KeyPath<Root, NSNumber?>, rhs: NSNumber) -> KeyPathFilter<Root, NSNumber?> {
    KeyPathFilter(keyPath: lhs.keyPath, greaterThan: rhs)
}

public func >= <Root: NSManagedObject>(lhs: KeyPath<Root, NSNumber?>, rhs: NSNumber) -> KeyPathFilter<Root, NSNumber?> {
    KeyPathFilter(keyPath: lhs.keyPath, greaterThanOrEqualTo: rhs)
}

// MARK: NSNumber

public func == <Root: NSManagedObject>(lhs: KeyPath<Root, NSNumber>, rhs: NSNumber?) -> KeyPathFilter<Root, NSNumber> {
    KeyPathFilter(keyPath: lhs.keyPath, equals: rhs)
}

public func != <Root: NSManagedObject>(lhs: KeyPath<Root, NSNumber>, rhs: NSNumber?) -> KeyPathFilter<Root, NSNumber> {
    KeyPathFilter(keyPath: lhs.keyPath, notEquals: rhs)
}

public func < <Root: NSManagedObject>(lhs: KeyPath<Root, NSNumber>, rhs: NSNumber) -> KeyPathFilter<Root, NSNumber> {
    KeyPathFilter(keyPath: lhs.keyPath, lessThan: rhs)
}

public func <= <Root: NSManagedObject>(lhs: KeyPath<Root, NSNumber>, rhs: NSNumber) -> KeyPathFilter<Root, NSNumber> {
    KeyPathFilter(keyPath: lhs.keyPath, lessThanOrEqualTo: rhs)
}

public func > <Root: NSManagedObject>(lhs: KeyPath<Root, NSNumber>, rhs: NSNumber) -> KeyPathFilter<Root, NSNumber> {
    KeyPathFilter(keyPath: lhs.keyPath, greaterThan: rhs)
}

public func >= <Root: NSManagedObject>(lhs: KeyPath<Root, NSNumber>, rhs: NSNumber) -> KeyPathFilter<Root, NSNumber> {
    KeyPathFilter(keyPath: lhs.keyPath, greaterThanOrEqualTo: rhs)
}

#endif
