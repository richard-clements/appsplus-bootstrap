#if canImport(Foundation)

import Foundation

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public struct AsynchronousUpdateRequest<T>: AsynchronousPersistentStoreRequest {
    
    typealias ReturnType = T
    public typealias Output = PersistentStoreUpdate
    
    public let publisher: Publisher
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
    
    public func sorted<Value>(by keyPath: KeyPath<T, Value>, ascending: Bool) -> AsynchronousUpdateRequest {
        AsynchronousUpdateRequest(publisher: publisher, fetchRequest: fetchRequest.sorted(by: keyPath, ascending: ascending))
    }
    
    public func suchThat(predicate: NSPredicate) -> AsynchronousUpdateRequest<T> {
        AsynchronousUpdateRequest(publisher: publisher, fetchRequest: fetchRequest.suchThat(predicate: predicate))
    }
    
    public func and(predicate: NSPredicate) -> AsynchronousUpdateRequest<T> {
        AsynchronousUpdateRequest(publisher: publisher, fetchRequest: fetchRequest.and(predicate: predicate))
    }
    
    public func or(predicate: NSPredicate) -> AsynchronousUpdateRequest<T> {
        AsynchronousUpdateRequest(publisher: publisher, fetchRequest: fetchRequest.or(predicate: predicate))
    }
    
    public func excluding(predicate: NSPredicate) -> AsynchronousUpdateRequest<T> {
        AsynchronousUpdateRequest(publisher: publisher, fetchRequest: fetchRequest.excluding(predicate: predicate))
    }
    
    public func modify(_ modifier: @escaping (T, SynchronousStorage) -> Void) -> AsynchronousUpdateRequest<T> {
        AsynchronousUpdateRequest(publisher: publisher, fetchRequest: fetchRequest.modify(modifier))
    }
    
    public func modify(_ modifier: @escaping (T) -> Void) -> AsynchronousUpdateRequest<T> {
        AsynchronousUpdateRequest(publisher: publisher, fetchRequest: fetchRequest.modify(modifier))
    }
}

#endif
