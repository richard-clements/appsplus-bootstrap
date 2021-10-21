#if canImport(Foundation) && canImport(Combine) && canImport(CoreData)

import XCTest
import Foundation
import Combine
import CoreData
@testable import AppsPlusData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class PersistentContainerTests: XCTestCase {
    
    var model: MockManagedObjectModel!
    var container: PersistentContainer!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        model = .default
        container = PersistentContainer(name: "TestModel", managedObjectModel: model)
        cancellables = Set()
        let expectation = XCTestExpectation()
        container.loadPersistentStores { _,_  in
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
        writeItems()
    }
    
    override func tearDownWithError() throws {
        model = nil
        cancellables = nil
        container = nil
    }
    
    func writeItems() {
        let expectation = XCTestExpectation()
        container.contextForWriting()
            .sink { _ in
                expectation.fulfill()
            } receiveValue: { context in
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: TestEntity.fetchRequest())
                _ = try? context.execute(deleteRequest)
                
                (Int32(0)..<100).forEach {
                    let object = TestEntity(context: context)
                    object.id = $0
                    object.name = "Name \($0)"
                }
                try! context.save()
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 1)
    }
    
    func testReceiveItemInScope() {
        let fetchRequest = TestEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.returnsObjectsAsFaults = false
        
        let context = container.newBackgroundContext()
        let expectation = XCTestExpectation()
        var entity: TestEntity?
        context.perform { [unowned self] in
            let item: TestEntity = (try! context.fetch(fetchRequest)).first as! TestEntity
            
            Just(item)
                .receive(in: .main)
                .sink(receiveCompletion: { _ in
                    expectation.fulfill()
                }) {
                    entity = $0
                }
                .store(in: &cancellables)
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(container.viewContext, entity?.managedObjectContext)
    }
    
    func testReceiveItemsInScope() {
        let fetchRequest = TestEntity.fetchRequest()
        fetchRequest.returnsObjectsAsFaults = false
        
        let context = container.newBackgroundContext()
        let expectation = XCTestExpectation()
        var entities: [TestEntity]?
        context.perform { [unowned self] in
            let items: [TestEntity] = (try! context.fetch(fetchRequest)) as! [TestEntity]
            
            Just(items)
                .receive(in: .main)
                .sink(receiveCompletion: { _ in
                    expectation.fulfill()
                }) {
                    entities = $0
                }
                .store(in: &cancellables)
        }
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(true, entities?.allSatisfy { $0.managedObjectContext == container.viewContext })
        XCTAssertEqual(100, entities?.count)
    }
    
}

#endif
