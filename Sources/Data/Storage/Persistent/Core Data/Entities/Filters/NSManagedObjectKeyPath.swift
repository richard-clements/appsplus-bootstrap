#if canImport(Foundation) && canImport(Combine)

import Foundation
import CoreData

extension KeyPath where Root: NSManagedObject {
    
    var keyPath: String {
        NSExpression(forKeyPath: self).keyPath
    }
    
}

#endif
