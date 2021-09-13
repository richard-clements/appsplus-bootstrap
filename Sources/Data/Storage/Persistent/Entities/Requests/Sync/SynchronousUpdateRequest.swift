#if canImport(Foundation)

import Foundation

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public struct SynchronousUpdateRequest<T>: SynchronousPersistentStoreRequest {
    
    public typealias Entity = T
    public typealias Output = Void
    
    let executor: Executor
    let fetchRequest: UpdateRequest<T>
    
    var shouldUpdate: Bool {
        fetchRequest.shouldUpdate
    }
    
    var shouldCreate: Bool {
        fetchRequest.shouldCreate
    }
    
    var prevalidator: ((T, SynchronousStorage) -> Bool)? {
        fetchRequest.prevalidator
    }
    
    var modifier: ((T, SynchronousStorage) -> Void)? {
        fetchRequest.modifier
    }
    
    public func sorted<Value>(by keyPath: KeyPath<T, Value>, ascending: Bool) -> SynchronousUpdateRequest {
        SynchronousUpdateRequest(executor: executor, fetchRequest: fetchRequest.sorted(by: keyPath, ascending: ascending))
    }
    
    public func limit(_ limit: Int) -> SynchronousUpdateRequest {
        SynchronousUpdateRequest(executor: executor, fetchRequest: fetchRequest.limit(limit))
    }
    
    public func offset(_ offset: Int) -> SynchronousUpdateRequest {
        SynchronousUpdateRequest(executor: executor, fetchRequest: fetchRequest.offset(offset))
    }
    
    public func batchSize(_ batchSize: Int) -> SynchronousUpdateRequest {
        SynchronousUpdateRequest(executor: executor, fetchRequest: fetchRequest.batchSize(batchSize))
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
    
    public func prevalidate(_ validation: @escaping (T, SynchronousStorage) -> Bool) -> SynchronousUpdateRequest<T> {
        SynchronousUpdateRequest(executor: executor, fetchRequest: fetchRequest.prevalidate(validation))
    }
    
    public func prevalidate(_ validation: @escaping (T) -> Bool) -> SynchronousUpdateRequest<T> {
        SynchronousUpdateRequest(executor: executor, fetchRequest: fetchRequest.prevalidate(validation))
    }
    
    public func modify(_ modifier: @escaping (T, SynchronousStorage) -> Void) -> SynchronousUpdateRequest<T> {
        SynchronousUpdateRequest(executor: executor, fetchRequest: fetchRequest.modify(modifier))
    }
    
    public func modify(_ modifier: @escaping (T) -> Void) -> SynchronousUpdateRequest<T> {
        SynchronousUpdateRequest(executor: executor, fetchRequest: fetchRequest.modify(modifier))
    }
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension SynchronousUpdateRequest: PersistentStoreRequest {
    
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
extension SynchronousUpdateRequest: FilterRequest { }

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension SynchronousUpdateRequest {
    
    public func perform() -> Output {
        executor(self)
    }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension SynchronousUpdateRequest: Equatable {
    
    public static func == (lhs: SynchronousUpdateRequest, rhs: SynchronousUpdateRequest) -> Bool {
        lhs.limit == rhs.limit &&
            lhs.offset == rhs.offset &&
            lhs.batchSize == rhs.batchSize &&
            lhs.predicate == rhs.predicate &&
            lhs.sortDescriptors == rhs.sortDescriptors &&
            lhs.shouldCreate && rhs.shouldCreate &&
            lhs.shouldUpdate == rhs.shouldUpdate
    }
    
}

#endif
