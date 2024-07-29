#if canImport(Foundation) && canImport(CoreData) && canImport(Combine)

import Foundation
import CoreData
import Combine

extension String {
    fileprivate static let contextProvider = "ContextProvider"
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public protocol CoreDataPersistentContainer {
    
    func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void)
    func contextForWriting() -> AnyPublisher<NSManagedObjectContext, Error>
    func contextForReading() -> AnyPublisher<NSManagedObjectContext, Error>
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public class PersistentContainer: NSPersistentContainer, CoreDataPersistentContainer {
    
    enum PersistentContainerError: Error {
        case writeUnavailable
        case readUnavailable
        case saveFailure(error: Error?)
    }
    
    private var cancellables = Set<AnyCancellable>()
    private weak var _writeContext: NSManagedObjectContext?
    private var writeContext: NSManagedObjectContext {
        if let context = _writeContext {
            return context
        } else {
            let context = newBackgroundContext()
            _writeContext = context
            return context
        }
    }
    private var readContexts = [NSManagedContextScope: NSManagedObjectContext]()
    private var lastUsedContexts = [NSManagedContextScope: Date]()
    private let readContextsQueue = DispatchQueue(label: "PersistentContainer.\(UUID().uuidString).ReadContexts")
    private let readContextTimeOut: TimeInterval = 5 * 60
    
    public override func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
        super.loadPersistentStores { [weak self] in
            self?.handleSave()
            self?.startDestroyTimer()
            self?.viewContext.performAndWait { [weak self] in
                self?.viewContext.userInfo[String.contextProvider] = { [weak self] in self as NSManagedContextProvider?}
            }
            block($0, $1)
        }
    }
    
    public override func newBackgroundContext() -> NSManagedObjectContext {
        let context = super.newBackgroundContext()
        context.performAndWait {
            context.userInfo[String.contextProvider] = { [weak self] in self as NSManagedContextProvider? }
        }
        return context
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
    
    public func contextForReading() -> AnyPublisher<NSManagedObjectContext, Error> {
        let context = backgroundContext()
        return Future { promise in
            context.perform {
                promise(.success(context))
            }
        }.eraseToAnyPublisher()
    }
    
    private func handleSave() {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: writeContext)
            .sink { [unowned self] note in
                viewContext.perform { [weak self] in
                    self?.viewContext.mergeChanges(fromContextDidSave: note)
                }
            }
            .store(in: &cancellables)
    }
}

extension PersistentContainer: NSManagedContextProvider {
    
    func context(for scope: NSManagedContextScope) -> NSManagedObjectContext? {
        switch scope {
        case .main:
            return viewContext
        case .write:
            return writeContext
        default:
            return readContextsQueue.sync {
                if readContexts[scope] == nil {
                    readContexts[scope] = backgroundContext()
                }
                lastUsedContexts[scope] = Date()
                return readContexts[scope]!
            }
        }
    }
}

extension NSManagedObjectContext {
    func context(for scope: NSManagedContextScope) -> NSManagedObjectContext? {
        (userInfo[String.contextProvider] as? (() -> NSManagedContextProvider?))?()?.context(for: scope)
    }
}

#endif
