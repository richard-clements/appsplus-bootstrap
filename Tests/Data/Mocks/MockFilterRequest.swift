#if canImport(Foundation)

import Foundation
@testable import AppsPlusData

struct MockFilterRequest<Entity>: FilterRequest {
    
    var suchThatPredicates = [NSPredicate]()
    var orPredicates = [NSPredicate]()
    var andPredicates = [NSPredicate]()
    var excludingPredicates = [NSPredicate]()
    
    func suchThat(predicate: NSPredicate) -> MockFilterRequest<Entity> {
        var mutable = self
        mutable.suchThatPredicates.append(predicate)
        return mutable
    }
    
    func or(predicate: NSPredicate) -> MockFilterRequest<Entity> {
        var mutable = self
        mutable.orPredicates.append(predicate)
        return mutable
    }
    
    func and(predicate: NSPredicate) -> MockFilterRequest<Entity> {
        var mutable = self
        mutable.andPredicates.append(predicate)
        return mutable
    }
    
    func excluding(predicate: NSPredicate) -> MockFilterRequest<Entity> {
        var mutable = self
        mutable.excludingPredicates.append(predicate)
        return mutable
    }
    
}

#endif
