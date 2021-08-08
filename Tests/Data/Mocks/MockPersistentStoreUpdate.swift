#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine
@testable import AppsPlusData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
struct MockPersistentStoreUpdate: PersistentStoreUpdate {
    
    let identifier: String
    
    func commit() -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

#endif
