#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
protocol AsynchronousPersistentStoreRequest {
    
    associatedtype Output
    typealias PublisherType = (Self) -> AnyPublisher<Output, Error>
    
    var publisher: PublisherType { get }
    
}

#endif
