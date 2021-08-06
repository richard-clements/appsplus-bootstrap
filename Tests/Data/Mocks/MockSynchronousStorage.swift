#if canImport(Foundation)

import Foundation
@testable import AppsPlusData

class MockSynchronousStorage: SynchronousStorage {
    
    func entity<EntityType>(_ type: EntityType.Type) -> AnySynchronousEntity<EntityType> {
        MockSynchronousEntity().eraseToAnyEntity()
    }
}

#endif
