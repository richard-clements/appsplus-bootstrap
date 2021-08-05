#if canImport(Foundation)

import Foundation

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
struct FetchRequest<T> {
    
    static func empty() -> FetchRequest {
        FetchRequest(predicate: nil, sortDescriptors: nil, limit: nil, offset: nil, batchSize: nil)
    }
    
    let predicate: NSPredicate?
    let sortDescriptors: [NSSortDescriptor]?
    let limit: Int?
    let offset: Int?
    let batchSize: Int?
    
    func sorted<Value>(by keyPath: KeyPath<T, Value>, ascending: Bool) -> FetchRequest {
        let sortDescriptors = [
            self.sortDescriptors,
            [NSSortDescriptor(keyPath: keyPath, ascending: ascending)]
        ]
        .compactMap { $0 }
        .flatMap { $0 }
        
        return join(FetchRequest(predicate: nil, sortDescriptors: sortDescriptors, limit: nil, offset: nil, batchSize: nil))
    }
    
    private func setPredicate(_ predicate: NSPredicate) -> FetchRequest<T> {
        join(FetchRequest(predicate: predicate, sortDescriptors: nil, limit: nil, offset: nil, batchSize: nil))
    }
    
    func suchThat(predicate: NSPredicate) -> FetchRequest<T> {
        setPredicate(PredicateHelper.suchThat(predicate: predicate, from: self.predicate))
    }
    
    func and(predicate: NSPredicate) -> FetchRequest<T> {
        setPredicate(PredicateHelper.and(predicate: predicate, from: self.predicate))
    }
    
    func or(predicate: NSPredicate) -> FetchRequest<T> {
        setPredicate(PredicateHelper.or(predicate: predicate, from: self.predicate))
    }
    
    func excluding(predicate: NSPredicate) -> FetchRequest<T> {
        setPredicate(PredicateHelper.excluding(predicate: predicate, from: self.predicate))
    }
    
    func limit(_ limit: Int) -> FetchRequest<T> {
        join(FetchRequest(predicate: nil, sortDescriptors: nil, limit: limit, offset: nil, batchSize: nil))
    }
    
    func offset(_ offset: Int) -> FetchRequest<T> {
        join(FetchRequest(predicate: nil, sortDescriptors: nil, limit: nil, offset: offset, batchSize: nil))
    }
    
    func batchSize(_ batchSize: Int) -> FetchRequest<T> {
        join(FetchRequest(predicate: nil, sortDescriptors: nil, limit: nil, offset: nil, batchSize: batchSize))
    }
    
    private func join(_ request: FetchRequest) -> FetchRequest {
        return FetchRequest(predicate: request.predicate ?? predicate, sortDescriptors: request.sortDescriptors ?? sortDescriptors, limit: request.limit ?? limit, offset: request.offset ?? offset, batchSize: request.batchSize ?? batchSize)
    }
}

#endif
