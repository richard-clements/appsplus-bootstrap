#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine
@testable import AppsPlusData

struct MockPersistentStoreUpdate: PersistentStoreUpdate {
    
    let identifier: String
    
    func commit() -> AnyPublisher<Void, Error> {
        Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

#endif
