#if canImport(Foundation)

import Foundation
@testable import AppsPlusData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class MockSynchronousStorage: SynchronousStorage {
    
    func entity<EntityType>(_ type: EntityType.Type) -> AnySynchronousEntity<EntityType> {
        MockSynchronousEntity().eraseToAnyEntity()
    }
}

#endif
