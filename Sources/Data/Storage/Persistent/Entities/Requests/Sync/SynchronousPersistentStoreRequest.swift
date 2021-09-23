#if canImport(Foundation)

import Foundation

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
protocol SynchronousPersistentStoreRequest {
    
    associatedtype Output
    typealias ExecutorFunction = (Self) -> Output
    
    var executor: ExecutorFunction { get }
    
}

#endif
