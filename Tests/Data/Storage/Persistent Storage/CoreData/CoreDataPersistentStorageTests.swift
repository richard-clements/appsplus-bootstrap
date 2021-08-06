#if canImport(Foundation) && canImport(Combine)

import XCTest
import Foundation
import Combine
@testable import AppsPlusData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class CoreDataPersistentStorageTests: XCTestCase {
    
    var coreDataStack: MockCoreDataStack!
    var storage: CoreDataPersistentStorage!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        cancellables = Set()
        coreDataStack = MockCoreDataStack()
        storage = CoreDataPersistentStorage(container: coreDataStack.container)
    }
    
    override func tearDownWithError() throws {
        cancellables = nil
        coreDataStack = nil
        storage = nil
    }
    
    func testEntity() {
        XCTAssertNotNil(storage.entity(TestEntity.self))
    }
    
    func testFetchPerform_ReturnsAddedObject() {
        let object = TestEntity(context: coreDataStack.container.writingContext)
        object.id = 1
        object.name = "Name"
        try! coreDataStack.container.writingContext.save()
        
        let expectation = XCTestExpectation()
        var results: [TestEntity]?
        
        storage.entity(TestEntity.self)
            .fetch()
            .perform()
            .sink { _ in
                expectation.fulfill()
            } receiveValue: {
                results = $0
            }
            .store(in: &cancellables)
            
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual([1], results?.map(\.id))
        XCTAssertEqual(["Name"], results?.map(\.name))
    }
    
    func testFetchSubscribe_ReturnsAddedObject() {
        let object = TestEntity(context: coreDataStack.container.writingContext)
        object.id = 1
        object.name = "Name"
        try! coreDataStack.container.writingContext.save()
        
        let expectation = XCTestExpectation()
        var results: [TestEntity]?
        
        storage.entity(TestEntity.self)
            .fetch()
            .subscribe()
            .first()
            .sink { _ in
                expectation.fulfill()
            } receiveValue: {
                results = $0
            }
            .store(in: &cancellables)
            
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual([1], results?.map(\.id))
        XCTAssertEqual(["Name"], results?.map(\.name))
    }
    
    func testFetchSubscribe_FiresWithUpdateObject() {
        let object = TestEntity(context: coreDataStack.container.writingContext)
        object.id = 1
        object.name = "Name 1"
        try! coreDataStack.container.writingContext.save()
        
        var firstFired = false
        let firstExpectation = XCTestExpectation()
        let secondExpectation = XCTestExpectation()
        var results: [TestEntity]?
        
        storage.entity(TestEntity.self)
            .fetch()
            .subscribe()
            .sink { _ in
            } receiveValue: {
                if firstFired {
                    secondExpectation.fulfill()
                }
                firstExpectation.fulfill()
                firstFired = true
                results = $0
            }
            .store(in: &cancellables)
            
        wait(for: [firstExpectation], timeout: 1)
        let object2 = TestEntity(context: coreDataStack.container.writingContext)
        object2.id = 2
        object2.name = "Name 2"
        try! coreDataStack.container.writingContext.save()
        
        wait(for: [secondExpectation], timeout: 1)
        
        XCTAssertEqual([1, 2], results?.map(\.id))
        XCTAssertEqual(["Name 1", "Name 2"], results?.map(\.name))
    }
    
    func testDelete_DeletesObjects() {
        let object = TestEntity(context: coreDataStack.container.writingContext)
        object.id = 1
        object.name = "Name 1"
        try! coreDataStack.container.writingContext.save()
        
        let expectation = XCTestExpectation()
        
        storage.entity(TestEntity.self)
            .delete()
            .perform()
            .save()
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertTrue(coreDataStack.container.attemptedBatchDelete)
    }
    
    func testCreate_CreatesNewObject() {
        let object = TestEntity(context: coreDataStack.container.writingContext)
        object.id = 1
        object.name = "Name 1"
        try! coreDataStack.container.writingContext.save()
        
        let expectation = XCTestExpectation()
        
        storage.entity(TestEntity.self)
            .create()
            .modify {
                $0.id = 1
                $0.name = "Name 1"
            }
            .perform()
            .save()
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        
        let fetchRequest = TestEntity.fetchRequest()
        let result = try! coreDataStack.container.viewContext.fetch(fetchRequest).compactMap { $0 as? TestEntity }
        
        XCTAssertEqual([1, 1], result.map(\.id))
        XCTAssertEqual(["Name 1", "Name 1"], result.map(\.name))
    }
    
    func testUpdateOrCreate_UpdatesObject() {
        let object = TestEntity(context: coreDataStack.container.writingContext)
        object.id = 1
        object.name = "Name 1"
        try! coreDataStack.container.writingContext.save()
        
        let expectation = XCTestExpectation()
        
        storage.entity(TestEntity.self)
            .update(orCreate: true)
            .suchThat(predicate: NSPredicate(format: "id == 1"))
            .modify {
                $0.id = 1
                $0.name = "Name 2"
            }
            .perform()
            .save()
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        
        let fetchRequest = TestEntity.fetchRequest()
        let result = try! coreDataStack.container.viewContext.fetch(fetchRequest).compactMap { $0 as? TestEntity }
        
        XCTAssertEqual([1], result.map(\.id))
        XCTAssertEqual(["Name 2"], result.map(\.name))
    }
    
    func testUpdate_UpdatesObject() {
        let object = TestEntity(context: coreDataStack.container.writingContext)
        object.id = 1
        object.name = "Name 1"
        try! coreDataStack.container.writingContext.save()
        
        let expectation = XCTestExpectation()
        
        storage.entity(TestEntity.self)
            .update()
            .suchThat(predicate: NSPredicate(format: "id == 1"))
            .modify {
                $0.id = 1
                $0.name = "Name 2"
            }
            .perform()
            .save()
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        
        let fetchRequest = TestEntity.fetchRequest()
        let result = try! coreDataStack.container.viewContext.fetch(fetchRequest).compactMap { $0 as? TestEntity }
        
        XCTAssertEqual([1], result.map(\.id))
        XCTAssertEqual(["Name 2"], result.map(\.name))
    }
    
    func testUpdate_DoesNotCreate() {
        let expectation = XCTestExpectation()
        
        storage.entity(TestEntity.self)
            .update()
            .suchThat(predicate: NSPredicate(format: "id == 1"))
            .modify {
                $0.id = 1
                $0.name = "Name 2"
            }
            .perform()
            .save()
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        
        let fetchRequest = TestEntity.fetchRequest()
        let result = try! coreDataStack.container.viewContext.fetch(fetchRequest).compactMap { $0 as? TestEntity }
        
        XCTAssertTrue(result.isEmpty)
    }
    
    func testUpdateOrCreate_CreatesObject() {
        let expectation = XCTestExpectation()
        
        storage.entity(TestEntity.self)
            .update(orCreate: true)
            .suchThat(predicate: NSPredicate(format: "id == 1"))
            .modify {
                $0.id = 1
                $0.name = "Name 1"
            }
            .perform()
            .save()
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        
        let fetchRequest = TestEntity.fetchRequest()
        let result = try! coreDataStack.container.viewContext.fetch(fetchRequest).compactMap { $0 as? TestEntity }
        
        XCTAssertEqual([1], result.map(\.id))
        XCTAssertEqual(["Name 1"], result.map(\.name))
    }
    
    func testSynchronousFetch() {
        let object = TestEntity(context: coreDataStack.container.writingContext)
        object.id = 1
        object.name = "Name 1"
        try! coreDataStack.container.writingContext.save()
        
        let expectation = XCTestExpectation()
        
        var itemIds = [Int32]()
        var itemNames = [String]()
        
        storage.entity(TestEntity.self)
            .update()
            .suchThat(predicate: NSPredicate(format: "id == 1"))
            .modify { _, db in
                let items = db.entity(TestEntity.self)
                    .fetch()
                    .perform()
                itemIds = items.map(\.id)
                itemNames = items.map(\.name)
            }
            .perform()
            .save()
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertEqual([1], itemIds)
        XCTAssertEqual(["Name 1"], itemNames)
    }
    
    func testSynchronousCreate_CreatesNewObject() {
        let object = TestEntity(context: coreDataStack.container.writingContext)
        object.id = 1
        object.name = "Name 1"
        try! coreDataStack.container.writingContext.save()
        
        let expectation = XCTestExpectation()
        
        storage.entity(TestEntity.self)
            .update()
            .modify { _, db in
                db.entity(TestEntity.self)
                    .create()
                    .modify {
                        $0.id = 1
                        $0.name = "Name 1"
                    }
                    .perform()
            }
            .perform()
            .save()
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        
        let fetchRequest = TestEntity.fetchRequest()
        let result = try! coreDataStack.container.viewContext.fetch(fetchRequest).compactMap { $0 as? TestEntity }
        
        XCTAssertEqual([1, 1], result.map(\.id))
        XCTAssertEqual(["Name 1", "Name 1"], result.map(\.name))
    }
    
    func testSynchronousUpdateOrCreate_UpdatesObject() {
        let object = TestEntity(context: coreDataStack.container.writingContext)
        object.id = 1
        object.name = "Name 1"
        try! coreDataStack.container.writingContext.save()
        
        let expectation = XCTestExpectation()
        
        storage.entity(TestEntity.self)
            .update()
            .modify { _, db in
                db.entity(TestEntity.self)
                    .update(orCreate: true)
                    .suchThat(predicate: NSPredicate(format: "id == 1"))
                    .modify {
                        $0.id = 1
                        $0.name = "Name 2"
                    }
                    .perform()
            }
            .perform()
            .save()
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        
        let fetchRequest = TestEntity.fetchRequest()
        let result = try! coreDataStack.container.viewContext.fetch(fetchRequest).compactMap { $0 as? TestEntity }
        
        XCTAssertEqual([1], result.map(\.id))
        XCTAssertEqual(["Name 2"], result.map(\.name))
    }
    
    func testSynchronousUpdate_UpdatesObject() {
        let object = TestEntity(context: coreDataStack.container.writingContext)
        object.id = 1
        object.name = "Name 1"
        try! coreDataStack.container.writingContext.save()
        
        let expectation = XCTestExpectation()
        
        storage.entity(TestEntity.self)
            .update()
            .suchThat(predicate: NSPredicate(format: "id == 1"))
            .modify { _, db in
                db.entity(TestEntity.self)
                    .update()
                    .suchThat(predicate: NSPredicate(format: "id == 1"))
                    .modify {
                        $0.id = 1
                        $0.name = "Name 2"
                    }
                    .perform()
            }
            .perform()
            .save()
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        
        let fetchRequest = TestEntity.fetchRequest()
        let result = try! coreDataStack.container.viewContext.fetch(fetchRequest).compactMap { $0 as? TestEntity }
        
        XCTAssertEqual([1], result.map(\.id))
        XCTAssertEqual(["Name 2"], result.map(\.name))
    }
    
    func testSynchronousUpdate_DoesNotCreate() {
        let object = TestEntity(context: coreDataStack.container.writingContext)
        object.id = 1
        object.name = "Name 1"
        try! coreDataStack.container.writingContext.save()
        
        let expectation = XCTestExpectation()
        
        storage.entity(TestEntity.self)
            .update()
            .modify { _, db in
                db.entity(TestEntity.self)
                    .update()
                    .suchThat(predicate: NSPredicate(format: "id == 2"))
                    .modify {
                        $0.id = 2
                        $0.name = "Name 2"
                    }
                    .perform()
            }
            .perform()
            .save()
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        
        let fetchRequest = TestEntity.fetchRequest()
        let result = try! coreDataStack.container.viewContext.fetch(fetchRequest).compactMap { $0 as? TestEntity }
        
        XCTAssertEqual([1], result.map(\.id))
        XCTAssertEqual(["Name 1"], result.map(\.name))
    }
    
    func testSynchronousUpdateOrCreate_CreatesObject() {
        let object = TestEntity(context: coreDataStack.container.writingContext)
        object.id = 1
        object.name = "Name 1"
        try! coreDataStack.container.writingContext.save()
        
        let expectation = XCTestExpectation()
        
        storage.entity(TestEntity.self)
            .update()
            .modify { _, db in
                db.entity(TestEntity.self)
                    .update(orCreate: true)
                    .suchThat(predicate: NSPredicate(format: "id == 2"))
                    .modify {
                        $0.id = 2
                        $0.name = "Name 2"
                    }
                    .perform()
            }
            .perform()
            .save()
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        
        let fetchRequest = TestEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TestEntity.id, ascending: true)]
        let result = try! coreDataStack.container.viewContext.fetch(fetchRequest).compactMap { $0 as? TestEntity }
        
        XCTAssertEqual([1, 2], result.map(\.id))
        XCTAssertEqual(["Name 1", "Name 2"], result.map(\.name))
    }
}

#endif
