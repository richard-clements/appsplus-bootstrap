#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
enum CoreDataPersistentStorageError: Error {
    case storeUnavailable
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public class CoreDataPersistentStorage: PersistentStorage {
    
    let identifier = "CoreDataPersistentStorage.\(UUID().uuidString)"
    let container: CoreDataPersistentContainer
    
    public init(container: CoreDataPersistentContainer) {
        self.container = container
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    public func entity<T>(_ type: T.Type) -> AnyAsynchronousEntity<T> {
        AsynchronousCoreDataEntity(identifier: identifier) { [weak self] in
            self?.container.contextForWriting() ?? Fail(error: CoreDataPersistentStorageError.storeUnavailable).eraseToAnyPublisher()
        } readPublisher: { [weak self] in
            self?.container.contextForReading(inBackgroundScope: $0) ?? Fail(error: CoreDataPersistentStorageError.storeUnavailable).eraseToAnyPublisher()
        }
        .eraseToAnyEntity()
    }
    
    public func beginTransactions(_ modifier: @escaping (SynchronousStorage) throws -> Void) -> AnyPublisher<PersistentStoreUpdate, Error> {
        let identifier = self.identifier
        return container.contextForWriting()
            .tryMap { context in
                try modifier(SynchronousCoreDataStorage(identifier: identifier, context: context))
                return CoreDataUpdate(identifier: identifier, context: context)
            }
            .eraseToAnyPublisher()
    }
    
}

#endif
