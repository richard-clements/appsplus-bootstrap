#if canImport(Foundation)

import Foundation

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public struct SynchronousUpdateRequest<T>: SynchronousPersistentStoreRequest {
    
    public typealias ReturnType = T
    public typealias Output = Void
    
    public let executor: Executor
    let fetchRequest: UpdateRequest<T>
    
    var shouldUpdate: Bool {
        fetchRequest.shouldUpdate
    }
    
    var shouldCreate: Bool {
        fetchRequest.shouldCreate
    }
    
    var modifier: ((T, SynchronousStorage) -> Void)? {
        fetchRequest.modifier
    }
    
    public var limit: Int? {
        fetchRequest.limit
    }
    
    public var predicate: NSPredicate? {
        fetchRequest.predicate
    }
    
    public var offset: Int? {
        fetchRequest.offset
    }
    
    public var batchSize: Int? {
        fetchRequest.batchSize
    }
    
    public var sortDescriptors: [NSSortDescriptor]? {
        fetchRequest.sortDescriptors
    }
    
    public func sorted<Value>(by keyPath: KeyPath<T, Value>, ascending: Bool) -> SynchronousUpdateRequest {
        SynchronousUpdateRequest(executor: executor, fetchRequest: fetchRequest.sorted(by: keyPath, ascending: ascending))
    }
    
    public func suchThat(predicate: NSPredicate) -> SynchronousUpdateRequest<T> {
        SynchronousUpdateRequest(executor: executor, fetchRequest: fetchRequest.suchThat(predicate: predicate))
    }
    
    public func and(predicate: NSPredicate) -> SynchronousUpdateRequest<T> {
        SynchronousUpdateRequest(executor: executor, fetchRequest: fetchRequest.and(predicate: predicate))
    }
    
    public func or(predicate: NSPredicate) -> SynchronousUpdateRequest<T> {
        SynchronousUpdateRequest(executor: executor, fetchRequest: fetchRequest.or(predicate: predicate))
    }
    
    public func excluding(predicate: NSPredicate) -> SynchronousUpdateRequest<T> {
        SynchronousUpdateRequest(executor: executor, fetchRequest: fetchRequest.excluding(predicate: predicate))
    }
    
    public func modify(_ modifier: @escaping (T, SynchronousStorage) -> Void) -> SynchronousUpdateRequest<T> {
        SynchronousUpdateRequest(executor: executor, fetchRequest: fetchRequest.modify(modifier))
    }
    
    public func modify(_ modifier: @escaping (T) -> Void) -> SynchronousUpdateRequest<T> {
        SynchronousUpdateRequest(executor: executor, fetchRequest: fetchRequest.modify(modifier))
    }
}

#endif
