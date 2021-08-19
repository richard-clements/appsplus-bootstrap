#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine
@testable import AppsPlusData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension AsynchronousFetchRequest {
    
    public init(fetchRequest: FetchRequest<Entity>) {
        self.init(publisher: { _ in
            Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }, fetchRequest: fetchRequest)
    }
    
    public func evaluate(_ entity: Entity) -> Bool {
        predicate?.evaluate(with: entity) ?? true
    }
    
    public func sortResult(of entities: [Entity]) -> [Entity] {
        (entities as NSArray).sortedArray(using: sortDescriptors ?? []) as! [Entity]
    }
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension AsynchronousUpdateRequest {
    
    struct EmptySynchronousStorage: SynchronousStorage {
        
        struct Entity<EntityType>: SynchronousEntity {
            
            func create() -> SynchronousUpdateRequest<EntityType> {
                SynchronousUpdateRequest(executor: { _ in }, fetchRequest: .create())
            }
            
            func update(orCreate: Bool) -> SynchronousUpdateRequest<EntityType> {
                SynchronousUpdateRequest(executor: { _ in }, fetchRequest: .update(orCreate: orCreate))
            }
            
            func fetch() -> SynchronousFetchRequest<EntityType> {
                SynchronousFetchRequest(executor: { _ in [] }, fetchRequest: .empty())
            }
            
            func delete() -> SynchronousDeleteRequest<EntityType> {
                SynchronousDeleteRequest(executor: { _ in }, fetchRequest: .empty())
            }
        }
        
        func entity<EntityType>(_ type: EntityType.Type) -> AnySynchronousEntity<EntityType> {
            AnySynchronousEntity(entity: Entity())
        }
        
    }
    
    public init(fetchRequest: UpdateRequest<Entity>) {
        self.init(publisher: { _ in
            Fail(error: MockPersistentStorage.StorageError.failedToUpdate).eraseToAnyPublisher()
        }, fetchRequest: fetchRequest)
    }
    
    public func evaluate(_ entity: Entity) -> Bool {
        predicate?.evaluate(with: entity) ?? true
    }
    
    public func modifying(_ value: Entity) {
        modifier?(value, EmptySynchronousStorage())
    }
    
    public func sortResult(of entities: [Entity]) -> [Entity] {
        (entities as NSArray).sortedArray(using: sortDescriptors ?? []) as! [Entity]
    }
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension AsynchronousDeleteRequest {
    
    public init(fetchRequest: DeleteRequest<Entity>) {
        self.init(publisher: { _ in
            Fail(error: MockPersistentStorage.StorageError.failedToDelete).eraseToAnyPublisher()
        }, fetchRequest: fetchRequest)
    }
    
    public func evaluate(_ entity: Entity) -> Bool {
        predicate?.evaluate(with: entity) ?? true
    }
    
    public func sortResult(of entities: [Entity]) -> [Entity] {
        (entities as NSArray).sortedArray(using: sortDescriptors ?? []) as! [Entity]
    }
}

#endif
