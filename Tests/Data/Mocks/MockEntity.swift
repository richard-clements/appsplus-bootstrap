#if canImport(Foundation)

import Foundation

class MockEntity: NSObject {
    
    @objc var name: String
    @objc var identity: Int
    
    init(name: String, identity: Int) {
        self.name = name
        self.identity = identity
    }
    
}

#endif
