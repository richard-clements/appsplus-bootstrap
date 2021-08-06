#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public struct AsynchronousDeleteRequest<T>: AsynchronousPersistentStoreRequest {
    
    public typealias ReturnType = T
    public typealias Output = PersistentStoreUpdate
    
    let publisher: PublisherType
    let fetchRequest: DeleteRequest<T>
    
    public func sorted<Value>(by keyPath: KeyPath<T, Value>, ascending: Bool) -> AsynchronousDeleteRequest<T> {
        AsynchronousDeleteRequest(publisher: publisher, fetchRequest: fetchRequest.sorted(by: keyPath, ascending: ascending))
    }
    
    public func limit(_ limit: Int) -> AsynchronousDeleteRequest<T> {
        AsynchronousDeleteRequest(publisher: publisher, fetchRequest: fetchRequest.limit(limit))
    }
    
    public func offset(_ offset: Int) -> AsynchronousDeleteRequest<T> {
        AsynchronousDeleteRequest(publisher: publisher, fetchRequest: fetchRequest.offset(offset))
    }
    
    public func batchSize(_ batchSize: Int) -> AsynchronousDeleteRequest<T> {
        AsynchronousDeleteRequest(publisher: publisher, fetchRequest: fetchRequest.batchSize(batchSize))
    }
    
    public func suchThat(predicate: NSPredicate) -> AsynchronousDeleteRequest<T> {
        AsynchronousDeleteRequest(publisher: publisher, fetchRequest: fetchRequest.suchThat(predicate: predicate))
    }
    
    public func and(predicate: NSPredicate) -> AsynchronousDeleteRequest<T> {
        AsynchronousDeleteRequest(publisher: publisher, fetchRequest: fetchRequest.and(predicate: predicate))
    }
    
    public func or(predicate: NSPredicate) -> AsynchronousDeleteRequest<T> {
        AsynchronousDeleteRequest(publisher: publisher, fetchRequest: fetchRequest.or(predicate: predicate))
    }
    
    public func excluding(predicate: NSPredicate) -> AsynchronousDeleteRequest<T> {
        AsynchronousDeleteRequest(publisher: publisher, fetchRequest: fetchRequest.excluding(predicate: predicate))
    }
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension AsynchronousDeleteRequest: PersistentStoreRequest {
    
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
extension AsynchronousDeleteRequest {
    
    public func perform() -> AnyPublisher<Output, Error> {
        publisher(self)
    }
    
}

#endif
