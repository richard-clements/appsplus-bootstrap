#if canImport(Foundation)

import Foundation

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public struct AsynchronousFetchRequest<T>: AsynchronousPersistentStoreRequest {
    
    typealias ReturnType = T
    public typealias Output = [T]
    
    public let publisher: Publisher
    let fetchRequest: FetchRequest<T>
    
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
    
    public func sorted<Value>(by keyPath: KeyPath<T, Value>, ascending: Bool) -> AsynchronousFetchRequest {
        AsynchronousFetchRequest(publisher: publisher, fetchRequest: fetchRequest.sorted(by: keyPath, ascending: ascending))
    }
    
    public func suchThat(predicate: NSPredicate) -> AsynchronousFetchRequest<T> {
        AsynchronousFetchRequest(publisher: publisher, fetchRequest: fetchRequest.suchThat(predicate: predicate))
    }
    
    public func and(predicate: NSPredicate) -> AsynchronousFetchRequest<T> {
        AsynchronousFetchRequest(publisher: publisher, fetchRequest: fetchRequest.and(predicate: predicate))
    }
    
    public func or(predicate: NSPredicate) -> AsynchronousFetchRequest<T> {
        AsynchronousFetchRequest(publisher: publisher, fetchRequest: fetchRequest.or(predicate: predicate))
    }
    
    public func excluding(predicate: NSPredicate) -> AsynchronousFetchRequest<T> {
        AsynchronousFetchRequest(publisher: publisher, fetchRequest: fetchRequest.excluding(predicate: predicate))
    }
    
    public func limit(_ limit: Int) -> AsynchronousFetchRequest<T> {
        AsynchronousFetchRequest(publisher: publisher, fetchRequest: fetchRequest.limit(limit))
    }
    
    public func offset(_ offset: Int) -> AsynchronousFetchRequest<T> {
        AsynchronousFetchRequest(publisher: publisher, fetchRequest: fetchRequest.offset(offset))
    }
    
    public func batchSize(_ batchSize: Int) -> AsynchronousFetchRequest<T> {
        AsynchronousFetchRequest(publisher: publisher, fetchRequest: fetchRequest.batchSize(batchSize))
    }
    
}


#endif
