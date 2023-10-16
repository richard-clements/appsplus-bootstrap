#if canImport(Foundation) && canImport(Combine)

import Foundation
import CoreData

public protocol CVarArgConvertible {
    func asCVarArg() -> CVarArg
}

extension String: CVarArgConvertible {
    
    public func asCVarArg() -> CVarArg {
        self
    }
    
}

extension URL: CVarArgConvertible {
    
    public func asCVarArg() -> CVarArg {
        absoluteString
    }
    
}

extension UUID: CVarArgConvertible {
    
    public func asCVarArg() -> CVarArg {
        uuidString
    }
    
}

extension Date: CVarArgConvertible {
    
    public func asCVarArg() -> CVarArg {
        self as NSDate
    }
    
}

extension Int16: CVarArgConvertible {
    
    public func asCVarArg() -> CVarArg {
        NSNumber(value: self)
    }
}

extension Int32: CVarArgConvertible {
    
    public func asCVarArg() -> CVarArg {
        NSNumber(value: self)
    }
}

extension Int64: CVarArgConvertible {
    
    public func asCVarArg() -> CVarArg {
        NSNumber(value: self)
    }
}

extension Float: CVarArgConvertible {
    
    public func asCVarArg() -> CVarArg {
        NSNumber(value: self)
    }
}

extension Double: CVarArgConvertible {
    
    public func asCVarArg() -> CVarArg {
        NSNumber(value: self)
    }
}

extension Bool: CVarArgConvertible {
    
    public func asCVarArg() -> CVarArg {
        NSNumber(value: self)
    }
}

extension NSNumber: CVarArgConvertible {
    
    public func asCVarArg() -> CVarArg {
        self
    }
    
}

extension NSNumber: Comparable {
    
    public static func < (lhs: NSNumber, rhs: NSNumber) -> Bool {
        lhs.compare(rhs) == .orderedAscending
    }
    
}

// MARK:- Equality
// MARK: Optionals

public func == <S, T, Value: CVarArgConvertible>(lhs: TypeContainer<S, T>, rhs: Value?) -> KeyPathFilter<S, Value?> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == %@", rhs.asCVarArg()))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == nil"))
    }
}

public func != <S, T, Value: CVarArgConvertible>(lhs: TypeContainer<S, T>, rhs: Value?) -> KeyPathFilter<S, Value?> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != %@", rhs.asCVarArg()))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != nil"))
    }
}

// MARK: Non Optionals

public func == <S, T, Value: CVarArgConvertible>(lhs: TypeContainer<S, T>, rhs: Value?) -> KeyPathFilter<S, Value> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == %@", rhs.asCVarArg()))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) == nil"))
    }
}

public func != <S, T, Value: CVarArgConvertible>(lhs: TypeContainer<S, T>, rhs: Value?) -> KeyPathFilter<S, Value> {
    if let rhs = rhs {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != %@", rhs.asCVarArg()))
    } else {
        return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) != nil"))
    }
}

// MARK:- Comparable
// MARK: Optionals

public func < <S, T, Value: CVarArgConvertible & Comparable>(lhs: TypeContainer<S, T>, rhs: Value) -> KeyPathFilter<S, Value?> {
    return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) < %@", rhs.asCVarArg()))
}

public func <= <S, T, Value: CVarArgConvertible & Comparable>(lhs: TypeContainer<S, T>, rhs: Value) -> KeyPathFilter<S, Value?> {
    return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) <= %@", rhs.asCVarArg()))
}

public func > <S, T, Value: CVarArgConvertible & Comparable>(lhs: TypeContainer<S, T>, rhs: Value) -> KeyPathFilter<S, Value?> {
    return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) > %@", rhs.asCVarArg()))
}

public func >= <S, T, Value: CVarArgConvertible & Comparable>(lhs: TypeContainer<S, T>, rhs: Value) -> KeyPathFilter<S, Value?> {
    return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) >= %@", rhs.asCVarArg()))
}

// MARK: Non Optionals

public func < <S, T, Value: CVarArgConvertible & Comparable>(lhs: TypeContainer<S, T>, rhs: Value) -> KeyPathFilter<S, Value> {
    return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) < %@", rhs.asCVarArg()))
}

public func <= <S, T, Value: CVarArgConvertible & Comparable>(lhs: TypeContainer<S, T>, rhs: Value) -> KeyPathFilter<S, Value> {
    return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) <= %@", rhs.asCVarArg()))
}

public func > <S, T, Value: CVarArgConvertible & Comparable>(lhs: TypeContainer<S, T>, rhs: Value) -> KeyPathFilter<S, Value> {
    return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) > %@", rhs.asCVarArg()))
}

public func >= <S, T, Value: CVarArgConvertible & Comparable>(lhs: TypeContainer<S, T>, rhs: Value) -> KeyPathFilter<S, Value> {
    return KeyPathFilter(predicate: NSPredicate(format: "\(lhs.keyPath) >= %@", rhs.asCVarArg()))
}

#endif
