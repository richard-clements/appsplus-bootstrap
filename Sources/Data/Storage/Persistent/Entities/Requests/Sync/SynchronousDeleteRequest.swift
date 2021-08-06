#if canImport(Foundation)

import Foundation

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public struct SynchronousDeleteRequest<T>: SynchronousPersistentStoreRequest {
    
    public typealias ReturnType = T
    public typealias Output = Void
    
    public let executor: Executor
    let fetchRequest: DeleteRequest<T>
    
    public func suchThat(predicate: NSPredicate) -> SynchronousDeleteRequest<T> {
        SynchronousDeleteRequest(executor: executor, fetchRequest: fetchRequest.suchThat(predicate: predicate))
    }
    
    public func and(predicate: NSPredicate) -> SynchronousDeleteRequest<T> {
        SynchronousDeleteRequest(executor: executor, fetchRequest: fetchRequest.and(predicate: predicate))
    }
    
    public func or(predicate: NSPredicate) -> SynchronousDeleteRequest<T> {
        SynchronousDeleteRequest(executor: executor, fetchRequest: fetchRequest.or(predicate: predicate))
    }
    
    public func excluding(predicate: NSPredicate) -> SynchronousDeleteRequest<T> {
        SynchronousDeleteRequest(executor: executor, fetchRequest: fetchRequest.excluding(predicate: predicate))
    }
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension SynchronousDeleteRequest: PersistentStoreRequest {
    
    var limit: Int? {
        fetchRequest.limit
    }
    
    var predicate: NSPredicate? {
        fetchRequest.predicate
    }
    
    var offset: Int? {
        fetchRequest.offset
    }
    
    var batchSize: Int? {
        fetchRequest.batchSize
    }
    
    var sortDescriptors: [NSSortDescriptor]? {
        fetchRequest.sortDescriptors
    }
    
}

#endif
