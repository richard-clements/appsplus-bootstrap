#if canImport(Foundation)

import Foundation

extension KeyPath where Root: NSObject {
    
    var keyPath: String {
        NSExpression(forKeyPath: self).keyPath
    }
    
}

#endif
