#if canImport(Foundation)

import Foundation

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
protocol SynchronousPersistentStoreRequest {
    
    associatedtype Output
    typealias Executor = (Self) -> Output
    
    var executor: Executor { get }
    
}

#endif
