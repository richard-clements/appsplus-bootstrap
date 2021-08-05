#if canImport(Foundation)

import Foundation

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public protocol SynchronousPersistentStoreRequest: PersistentStoreRequest {
    
    associatedtype Output
    typealias Executor = (Self) -> Output
    
    var executor: Executor { get }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension SynchronousPersistentStoreRequest {
    
    public func perform() -> Output {
        executor(self)
    }
    
}

#endif
