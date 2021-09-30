#if canImport(Foundation) && canImport(CoreData) && canImport(Combine)

import Foundation
import CoreData
import Combine
import XCTest
@testable import AppsPlusData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class MockPersistentContainer: NSPersistentContainer, CoreDataPersistentContainer {
    
    var cancellables = Set<AnyCancellable>()
    let expectation = XCTestExpectation()
    
    lazy var writingContext: NSManagedObjectContext = {
        newBackgroundContext()
    }()
    
    override func newBackgroundContext() -> NSManagedObjectContext {
        let context = super.newBackgroundContext()
        context.userInfo["ContextProvider"] = { [weak self] in self as NSManagedContextProvider? }
        return context
    }
    
    func contextForWriting() -> AnyPublisher<NSManagedObjectContext, Error> {
        Future { [unowned self] promise in
            writingContext.perform {
                promise(.success(writingContext))
            }
        }.eraseToAnyPublisher()
    }
    
    func contextForReading() -> AnyPublisher<NSManagedObjectContext, Error> {
        Just(viewContext).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    override func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
        super.loadPersistentStores { [weak self] in
            if let self = self {
                NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
                    .sink { [weak self] note in
                        self?.viewContext.perform {
                            self?.viewContext.mergeChanges(fromContextDidSave: note)
                        }
                    }
                    .store(in: &self.cancellables)
            }
            self?.expectation.fulfill()
            self?.viewContext.userInfo["ContextProvider"] = { [weak self] in self as NSManagedContextProvider? }
            block($0, $1)
        }
    }
}

extension MockPersistentContainer: NSManagedContextProvider {
    
    func context(for scope: NSManagedContextScope) -> NSManagedObjectContext? {
        viewContext
    }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class MockManagedObjectModel: NSManagedObjectModel {
    
    static let `default` = MockManagedObjectModel()
    
    override init() {
        super.init()
        let testEntity = NSEntityDescription()
        testEntity.name = "TestEntity"
        testEntity.managedObjectClassName = NSStringFromClass(TestEntity.self)
        
        var properties = [NSAttributeDescription]()
        
        let idAttributeDescription = NSAttributeDescription()
        idAttributeDescription.name = "id"
        idAttributeDescription.attributeType = .integer32AttributeType
        idAttributeDescription.isOptional = false
        idAttributeDescription.defaultValue = 0
        properties.append(idAttributeDescription)
        
        let nameAttributeDescription = NSAttributeDescription()
        nameAttributeDescription.name = "name"
        nameAttributeDescription.attributeType = .stringAttributeType
        nameAttributeDescription.isOptional = false
        nameAttributeDescription.defaultValue = ""
        properties.append(nameAttributeDescription)
        
        testEntity.properties = properties
        
        entities = [testEntity]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
struct MockCoreDataStack {
    let container: MockPersistentContainer
    
    
    init() {
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        
        container = MockPersistentContainer(name: "TestModel", managedObjectModel: MockManagedObjectModel.default)
        container.persistentStoreDescriptions = [persistentStoreDescription]
    }
    
    func loadExpectation() -> XCTestExpectation {
        container.expectation
    }
}

#endif
