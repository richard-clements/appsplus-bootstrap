#if canImport(Foundation) && canImport(CoreData)

import Foundation
import CoreData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
struct SynchronousCoreDataEntity<EntityType>: SynchronousEntity {
    
    let context: NSManagedObjectContext
    
    func create() -> SynchronousUpdateRequest<EntityType> {
        SynchronousUpdateRequest(executor: { request in
            createOrUpdateExecutor(for: request)
        }, fetchRequest: .create())
    }
    
    func update(orCreate: Bool) -> SynchronousUpdateRequest<EntityType> {
        SynchronousUpdateRequest(executor: { request in
            createOrUpdateExecutor(for: request)
        }, fetchRequest: .update(orCreate: orCreate))
    }
    
    func fetch() -> SynchronousFetchRequest<EntityType> {
        SynchronousFetchRequest(executor: {
            CoreDataEntity(context: context).fetch(request: $0.asFetchRequest())
        }, fetchRequest: FetchRequest.empty())
    }
    
    func delete() -> SynchronousDeleteRequest<EntityType> {
        SynchronousDeleteRequest(executor: {
            _ = CoreDataEntity(context: context).delete(request: $0.asFetchRequest())
        }, fetchRequest: DeleteRequest.empty())
    }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension SynchronousCoreDataEntity {
    
    func createOrUpdateExecutor<EntityType>(for request: SynchronousUpdateRequest<EntityType>) {
        _ = CoreDataEntity(context: context).update(entityName: request.entityName, shouldCreate: request.shouldCreate, shouldUpdate: request.shouldUpdate, fetchRequest: request.asFetchRequest(), modifier: request.modifier)
    }
    
}


#endif
