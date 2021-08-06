#if canImport(Foundation) && canImport(CoreData) && canImport(Combine)

import Foundation
import CoreData
import Combine
@testable import AppsPlusData

class MockPersistentContainer: NSPersistentContainer, CoreDataPersistentContainer {
    
    lazy var writingContext: NSManagedObjectContext = {
        newBackgroundContext()
    }()
    
    func contextForWriting() -> AnyPublisher<NSManagedObjectContext, Error> {
        Just(writingContext).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func contextForReading(inBackgroundScope scope: AsynchronousFetchRequestBackgroundScope?) -> AnyPublisher<NSManagedObjectContext, Error> {
        Just(viewContext).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

struct MockCoreDataStack {
    let container: MockPersistentContainer
    
    init() {
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        container = MockPersistentContainer(name: "TestModel", managedObjectModel: NSManagedObjectModel.mergedModel(from: [.module])!)
        container.persistentStoreDescriptions = [persistentStoreDescription]
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
}

#endif
