#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine
@testable import AppsPlusData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension AsynchronousFetchRequest {
    
    public init(fetchRequest: FetchRequest<Entity>) {
        self.init(publisher: { _ in
            Just([]).setFailureType(to: Error.self).eraseToAnyPublisher()
        }, fetchRequest: fetchRequest)
    }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension AsynchronousUpdateRequest {
    
    public init(fetchRequest: UpdateRequest<Entity>) {
        self.init(publisher: { _ in
            Fail(error: MockPersistentStorage.StorageError.failedToUpdate).eraseToAnyPublisher()
        }, fetchRequest: fetchRequest)
    }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension AsynchronousDeleteRequest {
    
    public init(fetchRequest: DeleteRequest<Entity>) {
        self.init(publisher: { _ in
            Fail(error: MockPersistentStorage.StorageError.failedToDelete).eraseToAnyPublisher()
        }, fetchRequest: fetchRequest)
    }
    
}

#endif
