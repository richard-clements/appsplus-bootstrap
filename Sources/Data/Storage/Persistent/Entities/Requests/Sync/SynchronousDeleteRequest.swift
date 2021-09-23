#if canImport(Foundation)

import Foundation

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public struct SynchronousDeleteRequest<T>: SynchronousPersistentStoreRequest {
    
    public typealias Entity = T
    public typealias Output = Void
    
    let executor: ExecutorFunction
    let fetchRequest: DeleteRequest<T>
    
    public func sorted<Value>(by keyPath: KeyPath<T, Value>, ascending: Bool) -> SynchronousDeleteRequest<T> {
        SynchronousDeleteRequest(executor: executor, fetchRequest: fetchRequest.sorted(by: keyPath, ascending: ascending))
    }
    
    public func limit(_ limit: Int) -> SynchronousDeleteRequest<T> {
        SynchronousDeleteRequest(executor: executor, fetchRequest: fetchRequest.limit(limit))
    }
    
    public func offset(_ offset: Int) -> SynchronousDeleteRequest<T> {
        SynchronousDeleteRequest(executor: executor, fetchRequest: fetchRequest.offset(offset))
    }
    
    public func batchSize(_ batchSize: Int) -> SynchronousDeleteRequest<T> {
        SynchronousDeleteRequest(executor: executor, fetchRequest: fetchRequest.batchSize(batchSize))
    }
    
    
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

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension SynchronousDeleteRequest: FilterRequest { }

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension SynchronousDeleteRequest {
    
    public func perform() -> Output {
        executor(self)
    }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension SynchronousDeleteRequest: Equatable {
    
    public static func == (lhs: SynchronousDeleteRequest, rhs: SynchronousDeleteRequest) -> Bool {
        lhs.limit == rhs.limit &&
            lhs.offset == rhs.offset &&
            lhs.batchSize == rhs.batchSize &&
            lhs.predicate == rhs.predicate &&
            lhs.sortDescriptors == rhs.sortDescriptors
    }
    
}

#endif
