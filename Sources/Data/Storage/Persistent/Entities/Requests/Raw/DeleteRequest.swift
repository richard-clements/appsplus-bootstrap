#if canImport(Foundation)

import Foundation

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
struct DeleteRequest<T> {
    
    static func empty() -> DeleteRequest {
        DeleteRequest(predicate: nil, sortDescriptors: nil, limit: nil, offset: nil, batchSize: nil)
    }
    
    let predicate: NSPredicate?
    let sortDescriptors: [NSSortDescriptor]?
    let limit: Int?
    let offset: Int?
    let batchSize: Int?
    
    func sorted<Value>(by keyPath: KeyPath<T, Value>, ascending: Bool) -> DeleteRequest {
        let sortDescriptors = [
            self.sortDescriptors,
            [NSSortDescriptor(keyPath: keyPath, ascending: ascending)]
        ]
        .compactMap { $0 }
        .flatMap { $0 }
        
        return join(
            DeleteRequest(
                predicate: nil,
                sortDescriptors: sortDescriptors,
                limit: nil,
                offset: nil,
                batchSize: nil
            )
        )
    }
    
    private func setPredicate(_ predicate: NSPredicate) -> DeleteRequest {
        return join(
            DeleteRequest(
                predicate: predicate,
                sortDescriptors: nil,
                limit: nil,
                offset: nil,
                batchSize: nil
            )
        )
    }
    
    func suchThat(predicate: NSPredicate) -> DeleteRequest {
        let updatedPredicate = self.predicate.map { NSCompoundPredicate(andPredicateWithSubpredicates: [$0, predicate]) } ?? predicate
        return setPredicate(updatedPredicate)
    }
    
    func and(predicate: NSPredicate) -> DeleteRequest {
        guard self.predicate != nil else {
            fatalError("Can not `and` on empty predicate")
        }
        return suchThat(predicate: predicate)
    }
    
    func or(predicate: NSPredicate) -> DeleteRequest {
        guard let currentPredicate = self.predicate else {
            fatalError("Can not `or` on empty predicate")
        }
        let updatedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [currentPredicate, predicate])
        return setPredicate(updatedPredicate)
    }
    
    func excluding(predicate: NSPredicate) -> DeleteRequest {
        let updatedPredicate = self.predicate.map { NSCompoundPredicate(andPredicateWithSubpredicates: [$0, NSCompoundPredicate(notPredicateWithSubpredicate: predicate)]) } ?? NSCompoundPredicate(notPredicateWithSubpredicate: predicate)
        return setPredicate(updatedPredicate)
    }
    
    func limit(_ limit: Int) -> DeleteRequest {
        join(DeleteRequest(predicate: nil, sortDescriptors: nil, limit: limit, offset: nil, batchSize: nil))
    }
    
    func offset(_ offset: Int) -> DeleteRequest {
        join(DeleteRequest(predicate: nil, sortDescriptors: nil, limit: nil, offset: offset, batchSize: nil))
    }
    
    func batchSize(_ batchSize: Int) -> DeleteRequest {
        join(DeleteRequest(predicate: nil, sortDescriptors: nil, limit: nil, offset: nil, batchSize: batchSize))
    }
    
    private func join(_ request: DeleteRequest) -> DeleteRequest {
        DeleteRequest(
            predicate: request.predicate ?? predicate,
            sortDescriptors: request.sortDescriptors ?? sortDescriptors,
            limit: request.limit ?? limit,
            offset: request.offset ?? offset,
            batchSize: request.batchSize ?? batchSize
        )
    }
}


#endif
