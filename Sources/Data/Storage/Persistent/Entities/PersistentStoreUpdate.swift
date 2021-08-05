#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public enum PersistentStoreChange {
    case noChanges
    case inserted
    case updated
    case deleted
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public protocol PersistentStoreUpdate {
    var type: PersistentStoreChange { get }
    func commit() -> AnyPublisher<Void, Error>
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public struct PersistentStoreUpdateSkip: PersistentStoreUpdate {
    public let type: PersistentStoreChange = .noChanges
    public func commit() -> AnyPublisher<Void, Error> {
        return Just(())
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    public init() {}
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension Publisher where Output == PersistentStoreUpdate {
    
    func save() -> AnyPublisher<Void, Error> {
        filter { !($0 is PersistentStoreUpdateSkip) }
            .reduce(nil) { _, next in next }
            .replaceNil(with: PersistentStoreUpdateSkip())
            .mapError { $0 as Error }
            .flatMap { $0.commit() }
            .eraseToAnyPublisher()
    }
    
}

#endif
