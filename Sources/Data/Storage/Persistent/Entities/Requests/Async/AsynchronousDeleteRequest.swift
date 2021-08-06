#if canImport(Foundation)

import Foundation

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public struct AsynchronousDeleteRequest<T>: AsynchronousPersistentStoreRequest {
    
    public typealias ReturnType = T
    public typealias Output = PersistentStoreUpdate
    
    public let publisher: PublisherType
    let fetchRequest: DeleteRequest<T>
    
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

#endif
