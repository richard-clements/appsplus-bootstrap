#if canImport(Foundation) && canImport(CoreData) && canImport(Combine)

import Foundation
import CoreData
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public protocol CoreDataPersistentContainer {
    
    func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void)
    func contextForWriting() -> AnyPublisher<NSManagedObjectContext, Error>
    func contextForReading(inBackgroundScope scope: AsynchronousFetchRequestBackgroundScope?) -> AnyPublisher<NSManagedObjectContext, Error>
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public class PersistentContainer: NSPersistentContainer, CoreDataPersistentContainer {
    
    enum PersistentContainerError: Error {
        case writeUnavailable
        case readUnvailable
        case saveFailure(error: Error?)
    }
    
    private var cancellables = Set<AnyCancellable>()
    private var writeContext: NSManagedObjectContext?
    private var readContexts = [String: NSManagedObjectContext]()
    private var lastUsedContexts = [String: Date]()
    private let readContextsQueue = DispatchQueue(label: "PersistentContainer.\(UUID().uuidString).ReadContexts")
    private let readContextTimeOut: TimeInterval = 5 * 60
    
    public override func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
        super.loadPersistentStores { [weak self] in
            self?.writeContext = self?.newBackgroundContext()
            self?.handleSave()
            self?.startDestroyTimer()
            block($0, $1)
        }
    }
    
    private func startDestroyTimer() {
        Timer.publish(every: readContextTimeOut, on: .main, in: .common)
            .autoconnect()
            .receive(on: readContextsQueue)
            .map { [unowned self] _ in lastUsedContexts }
            .map { [unowned self] in
                $0.filter { Date().timeIntervalSince($0.value) >= readContextTimeOut }
            }
            .map { $0.keys }
            .sink { [unowned self] in
                $0.forEach {
                    readContexts[$0] = nil
                    lastUsedContexts[$0] = nil
                }
            }
            .store(in: &cancellables)
    }
    
    public func contextForWriting() -> AnyPublisher<NSManagedObjectContext, Error> {
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
    
    private func backgroundContext() -> NSManagedObjectContext {
        let context = newBackgroundContext()
        context.automaticallyMergesChangesFromParent = true
        return context
    }
    
    private func context(for scope: AsynchronousFetchRequestBackgroundScope?) -> NSManagedObjectContext {
        if scope == .new {
            return backgroundContext()
        } else if let scope = scope {
            return readContextsQueue.sync {
                if readContexts[scope.rawValue] == nil {
                    readContexts[scope.rawValue] = backgroundContext()
                }
                lastUsedContexts[scope.rawValue] = Date()
                return readContexts[scope.rawValue]!
            }
        } else {
            return viewContext
        }
    }
    
    public func contextForReading(inBackgroundScope scope: AsynchronousFetchRequestBackgroundScope?) -> AnyPublisher<NSManagedObjectContext, Error> {
        let context = self.context(for: scope)
        return Future { promise in
            context.perform {
                promise(.success(context))
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
