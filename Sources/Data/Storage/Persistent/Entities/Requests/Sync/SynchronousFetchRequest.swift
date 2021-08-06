#if canImport(Foundation)

import Foundation

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public struct SynchronousFetchRequest<T>: SynchronousPersistentStoreRequest {
    
    public typealias ReturnType = T
    public typealias Output = [T]
    
    public let executor: Executor
    let fetchRequest: FetchRequest<T>
    
    public var predicate: NSPredicate? {
        fetchRequest.predicate
    }
    
    public func sorted<Value>(by keyPath: KeyPath<T, Value>, ascending: Bool) -> SynchronousFetchRequest {
        SynchronousFetchRequest(executor: executor, fetchRequest: fetchRequest.sorted(by: keyPath, ascending: ascending))
    }
    
    public func suchThat(predicate: NSPredicate) -> SynchronousFetchRequest<T> {
        SynchronousFetchRequest(executor: executor, fetchRequest: fetchRequest.suchThat(predicate: predicate))
    }
    
    public func and(predicate: NSPredicate) -> SynchronousFetchRequest<T> {
        SynchronousFetchRequest(executor: executor, fetchRequest: fetchRequest.and(predicate: predicate))
    }
    
    public func or(predicate: NSPredicate) -> SynchronousFetchRequest<T> {
        SynchronousFetchRequest(executor: executor, fetchRequest: fetchRequest.or(predicate: predicate))
    }
    
    public func excluding(predicate: NSPredicate) -> SynchronousFetchRequest<T> {
        SynchronousFetchRequest(executor: executor, fetchRequest: fetchRequest.excluding(predicate: predicate))
    }
    
    public func limit(_ limit: Int) -> SynchronousFetchRequest<T> {
        SynchronousFetchRequest(executor: executor, fetchRequest: fetchRequest.limit(limit))
    }
    
    public func offset(_ offset: Int) -> SynchronousFetchRequest<T> {
        SynchronousFetchRequest(executor: executor, fetchRequest: fetchRequest.offset(offset))
    }
    
    public func batchSize(_ batchSize: Int) -> SynchronousFetchRequest<T> {
        SynchronousFetchRequest(executor: executor, fetchRequest: fetchRequest.batchSize(batchSize))
    }
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension SynchronousFetchRequest: PersistentStoreRequest {
    
    var sortDescriptors: [NSSortDescriptor]? {
        fetchRequest.sortDescriptors
    }
    
    var limit: Int? {
        fetchRequest.limit
    }
    
    var offset: Int? {
        fetchRequest.offset
    }
    
    var batchSize: Int? {
        fetchRequest.batchSize
    }
    
}

#endif
