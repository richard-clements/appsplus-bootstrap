#if canImport(Foundation)

import Foundation

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
struct PredicateHelper {
    
    static func suchThat(predicate: NSPredicate, from original: NSPredicate?) -> NSPredicate {
        original.map { NSCompoundPredicate(andPredicateWithSubpredicates: [$0, predicate]) } ?? predicate
    }
    
    static func and(predicate: NSPredicate, from original: NSPredicate?) -> NSPredicate {
        guard let original = original else {
            fatalError("Can not `and` on empty predicate")
        }
        return suchThat(predicate: predicate, from: original)
    }
    
    static func or(predicate: NSPredicate, from original: NSPredicate?) -> NSPredicate {
        guard let original = original else {
            fatalError("Can not `or` on empty predicate")
        }
        return NSCompoundPredicate(orPredicateWithSubpredicates: [original, predicate])
    }
    
    static func excluding(predicate: NSPredicate, from original: NSPredicate?) -> NSPredicate {
        original.map {
            NSCompoundPredicate(
                andPredicateWithSubpredicates: [
                    $0,
                    NSCompoundPredicate(notPredicateWithSubpredicate: predicate)
                ]
            )
        } ?? NSCompoundPredicate(notPredicateWithSubpredicate: predicate)
    }
}

#endif
