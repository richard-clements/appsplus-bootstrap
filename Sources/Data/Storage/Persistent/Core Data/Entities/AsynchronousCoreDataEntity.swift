#if canImport(Foundation) && canImport(Combine) && canImport(CoreData)

import Foundation
import CoreData
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
struct AsynchronousCoreDataEntity<EntityType>: AsynchronousEntity {
    
    typealias PublisherType = () -> AnyPublisher<NSManagedObjectContext, Error>
    
    let identifier: String
    let writePublisher: PublisherType
    let readPublisher: PublisherType
    
    func create() -> AsynchronousUpdateRequest<EntityType> {
        AsynchronousUpdateRequest(publisher: createOrUpdatePublisher, fetchRequest: .create())
    }
    
    func update(orCreate: Bool) -> AsynchronousUpdateRequest<EntityType> {
        AsynchronousUpdateRequest(publisher: createOrUpdatePublisher, fetchRequest: .update(orCreate: orCreate))
    }
    
    func fetch() -> AsynchronousFetchRequest<EntityType> {
        AsynchronousFetchRequest(publisher: { request in
            readPublisher()
                .flatMap { context -> AnyPublisher<[EntityType], Error> in
                    if request.shouldSubscribe {
                        return Just(CoreDataEntity(identifier: identifier, context: context).fetch(request: request.asFetchRequest()))
                            .setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    } else {
                        return CoreDataFetchResultsPublisher(context: context, fetchRequest: request.asFetchRequest())
                            .eraseToAnyPublisher()
                    }
                }
                .eraseToAnyPublisher()
        }, fetchRequest: .empty())
    }
    
    func delete() -> AsynchronousDeleteRequest<EntityType> {
        AsynchronousDeleteRequest(publisher: { request in
            writePublisher()
                .map { context -> PersistentStoreUpdate in
                    CoreDataEntity(identifier: identifier, context: context).delete(request: request.asFetchRequest())
                }
                .eraseToAnyPublisher()
        }, fetchRequest: .empty())
    }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension AsynchronousCoreDataEntity {
    
    func createOrUpdatePublisher<EntityType>(for request: AsynchronousUpdateRequest<EntityType>) -> AnyPublisher<PersistentStoreUpdate, Error> {
        writePublisher()
            .map {
                CoreDataEntity(identifier: identifier, context: $0).update(entityName: request.entityName, shouldCreate: request.shouldCreate, shouldUpdate: request.shouldUpdate, fetchRequest: request.asFetchRequest(), modifier: request.modifier)
            }
            .eraseToAnyPublisher()
    }
}

#endif
