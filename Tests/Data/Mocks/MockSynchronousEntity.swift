#if canImport(Foundation)

import Foundation
@testable import AppsPlusData

class MockSynchronousEntity<EntityType>: SynchronousEntity {
    
    var fetchResult = [EntityType]()
    
    func fetch() -> SynchronousFetchRequest<EntityType> {
        SynchronousFetchRequest(executor: { [weak self] _ in self?.fetchResult ?? [] }, fetchRequest: .empty())
    }
    
    func create() -> SynchronousUpdateRequest<EntityType> {
        SynchronousUpdateRequest(executor: { _ in }, fetchRequest: .create())
    }
    
    func update(orCreate: Bool) -> SynchronousUpdateRequest<EntityType> {
        SynchronousUpdateRequest(executor: { _ in }, fetchRequest: .update(orCreate: orCreate))
    }
    
    func delete() -> SynchronousDeleteRequest<EntityType> {
        SynchronousDeleteRequest(executor: { _ in }, fetchRequest: .empty())
    }
}

#endif
