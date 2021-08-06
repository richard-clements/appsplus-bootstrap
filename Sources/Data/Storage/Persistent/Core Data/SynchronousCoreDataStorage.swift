#if canImport(Foundation) && canImport(CoreData)

import Foundation
import CoreData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
struct SynchronousCoreDataStorage: SynchronousStorage {
    
    let context: NSManagedObjectContext
    
    func entity<EntityType>(_ type: EntityType.Type) -> AnySynchronousEntity<EntityType> {
        SynchronousCoreDataEntity(context: context).eraseToAnyEntity()
    }
    
}

#endif
