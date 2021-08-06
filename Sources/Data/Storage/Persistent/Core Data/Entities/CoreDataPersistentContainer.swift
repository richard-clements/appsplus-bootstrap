#if canImport(Foundation) && canImport(CoreData) && canImport(Combine)

import Foundation
import CoreData
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public protocol CoreDataPersistentContainer {
    
    func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void)
    func contextForWriting() -> AnyPublisher<NSManagedObjectContext, Error>
    func contextForReading() -> AnyPublisher<NSManagedObjectContext, Error>
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension CoreDataPersistentContainer {
    
    static func container(for name: String) -> CoreDataPersistentContainer {
        _CoreDataPersistentContainer(name: name)
    }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class _CoreDataPersistentContainer: NSPersistentContainer, CoreDataPersistentContainer {
    
    enum PersistentContainerError: Error {
        case writeUnavailable
        case readUnvailable
        case saveFailure(error: Error?)
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var writeContext: NSManagedObjectContext?
    
    override func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
        super.loadPersistentStores { [weak self] in
            self?.writeContext = self?.newBackgroundContext()
            self?.handleSave()
            block($0, $1)
        }
    }
    
    func contextForWriting() -> AnyPublisher<NSManagedObjectContext, Error> {
        Future { [weak self] promise in
            guard let writeContext = self?.writeContext else {
                promise(.failure(PersistentContainerError.writeUnavailable))
                return
            }
            writeContext.perform {
                promise(.success(writeContext))
            }
        }.eraseToAnyPublisher()
    }
    
    func contextForReading() -> AnyPublisher<NSManagedObjectContext, Error> {
        Future { [weak self] promise in
            guard let readContext = self?.viewContext else {
                promise(.failure(PersistentContainerError.readUnvailable))
                return
            }
            readContext.perform {
                promise(.success(readContext))
            }
        }.eraseToAnyPublisher()
    }
    
    private func handleSave() {
        guard let writeContext = writeContext else { return }
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: writeContext)
            .sink { [unowned self] in
                viewContext.mergeChanges(fromContextDidSave: $0)
            }
            .store(in: &cancellables)
    }
}

#endif
