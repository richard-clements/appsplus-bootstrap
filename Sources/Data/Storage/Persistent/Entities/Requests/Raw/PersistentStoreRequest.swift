#if canImport(Foundation)

import Foundation

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public enum PersistentStoreRequestError: Error {
    case noPersistentStore
    case invalidRequest
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public protocol PersistentStoreRequest {
    associatedtype ReturnType
    var predicate: NSPredicate? { get }
    var limit: Int? { get }
    var offset: Int? { get }
    var batchSize: Int? { get }
    var sortDescriptors: [NSSortDescriptor]? { get }
}


#endif
