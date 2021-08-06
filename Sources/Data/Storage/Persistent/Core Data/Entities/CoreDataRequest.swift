#if canImport(Foundation) && canImport(CoreData)

import Foundation
import CoreData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension PersistentStoreRequest {
    
    var entityName: String {
        guard let name = (ReturnType.self as? NSManagedObject.Type)?.entity().name else {
            fatalError("Invalid entity \(String(describing: ReturnType.self))")
        }
        return name
    }
    
    func asFetchRequest() -> NSFetchRequest<NSFetchRequestResult> {
        guard let type = ReturnType.self as? NSManagedObject.Type,
              let name = type.entity().name else {
            fatalError("Invalid entity \(String(describing: ReturnType.self))")
        }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        fetchRequest.predicate = predicate
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
        if let offset = offset {
            fetchRequest.fetchOffset = offset
        }
        if let batchSize = batchSize {
            fetchRequest.fetchBatchSize = batchSize
        }
        fetchRequest.sortDescriptors = sortDescriptors
        return fetchRequest
    }
    
}

#endif
