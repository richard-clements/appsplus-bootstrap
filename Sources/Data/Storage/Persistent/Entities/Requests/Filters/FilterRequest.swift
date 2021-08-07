#if canImport(Foundation) && canImport(CoreData)

import Foundation
import CoreData

public protocol FilterRequest {
    
    associatedtype Entity
    func suchThat(predicate: NSPredicate) -> Self
    func and(predicate: NSPredicate) -> Self
    func or(predicate: NSPredicate) -> Self
    
}

extension FilterRequest where Entity: NSManagedObject {
    
    public typealias KeyPathFilterBuilder<Value> = () -> KeyPathFilter<Entity, Value>
    
    public func suchThat<Value>(filter: KeyPathFilterBuilder<Value>) -> Self {
        suchThat(predicate: filter().predicate)
    }
    
    public func and<Value>(filter: KeyPathFilterBuilder<Value>) -> Self {
        and(predicate: filter().predicate)
    }
    
    public func or<Value>(filter: KeyPathFilterBuilder<Value>) -> Self {
        or(predicate: filter().predicate)
    }
    
}

#endif
