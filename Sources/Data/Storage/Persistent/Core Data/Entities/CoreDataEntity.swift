#if canImport(Foundation) && canImport(CoreData)

import Foundation
import CoreData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
struct CoreDataEntity {
    
    let identifier: String
    let context: NSManagedObjectContext
    
    func delete(request: NSFetchRequest<NSFetchRequestResult>) -> PersistentStoreUpdate {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        deleteRequest.resultType = .resultTypeCount
        let count = (try? context.execute(deleteRequest) as? NSBatchDeleteResult)?.result as? Int ?? 0
        return CoreDataUpdate(identifier: identifier, context: context, type: count > 0 ? PersistentStoreChange.deleted : .updated)
    }
    
    func update<EntityType>(entityName: String, shouldCreate: Bool, shouldUpdate: Bool, fetchRequest: NSFetchRequest<NSFetchRequestResult>, modifier: ((EntityType, SynchronousStorage) -> Void)?) -> PersistentStoreUpdate {
        if shouldUpdate {
            let fetchResults = (try? context.fetch(fetchRequest))?.compactMap { $0 as? EntityType } ?? []
            if fetchResults.isEmpty && !shouldCreate {
                return CoreDataUpdate(identifier: identifier, context: context, type: .noChanges)
            } else if fetchResults.isEmpty && shouldCreate {
                return create(entityName: entityName, modifier: modifier)
            } else {
                fetchResults.forEach {
                    modifier?($0, SynchronousCoreDataStorage(identifier: identifier, context: context))
                }
                return CoreDataUpdate(identifier: identifier, context: context, type: .updated)
            }
        } else if shouldCreate {
            return create(entityName: entityName, modifier: modifier)
        } else {
            return CoreDataUpdate(identifier: identifier, context: context, type: .noChanges)
        }
    }
    
    func fetch<EntityType>(request: NSFetchRequest<NSFetchRequestResult>) -> [EntityType] {
        (try? context.fetch(request))?.compactMap { $0 as? EntityType } ?? []
    }
    
    private func create<EntityType>(entityName: String, modifier: ((EntityType, SynchronousStorage) -> Void)?) -> PersistentStoreUpdate {
        guard let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as? EntityType else {
            return CoreDataUpdate(identifier: identifier, context: context, type: .noChanges)
        }
        modifier?(entity, SynchronousCoreDataStorage(identifier: identifier, context: context))
        return CoreDataUpdate(identifier: identifier, context: context, type: .inserted)
    }
    
}

#endif
