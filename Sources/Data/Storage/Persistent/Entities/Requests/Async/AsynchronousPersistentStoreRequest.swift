#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public protocol AsynchronousPersistentStoreRequest: PersistentStoreRequest {
    
    associatedtype Output
    typealias Publisher = (Self) -> AnyPublisher<Output, Error>
    
    var publisher: Publisher { get }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension AsynchronousPersistentStoreRequest {
    
    public func perform() -> AnyPublisher<Output, Error> {
        publisher(self)
    }
    
}

#endif
