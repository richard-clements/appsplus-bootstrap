#if canImport(Foundation)

import Foundation
@testable import AppsPlusData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
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
