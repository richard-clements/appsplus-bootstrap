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
    
    func contextForWriting() -> AnyPublisher<NSManagedObjectContext, Error> {
        Future { [unowned self] promise in
            writingContext.perform {
                promise(.success(writingContext))
            }
        }.eraseToAnyPublisher()
    }
    
    func contextForReading(inBackgroundScope scope: AsynchronousFetchRequestBackgroundScope?) -> AnyPublisher<NSManagedObjectContext, Error> {
        Just(viewContext).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    override func loadPersistentStores(completionHandler block: @escaping (NSPersistentStoreDescription, Error?) -> Void) {
        super.loadPersistentStores { [weak self] in
            if let self = self {
                NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)
                    .sink { [unowned self] in
                        self.viewContext.mergeChanges(fromContextDidSave: $0)
                    }
                    .store(in: &self.cancellables)
            }
            self?.expectation.fulfill()
            block($0, $1)
        }
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
