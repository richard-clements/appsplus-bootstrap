#if canImport(Foundation)

import Foundation

public protocol FilterRequest {
    
    associatedtype Entity
    func suchThat(predicate: NSPredicate) -> Self
    func and(predicate: NSPredicate) -> Self
    func or(predicate: NSPredicate) -> Self
    func excluding(predicate: NSPredicate) -> Self
    
}

#endif
