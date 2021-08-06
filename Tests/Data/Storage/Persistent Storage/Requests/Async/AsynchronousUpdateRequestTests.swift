#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine
import XCTest
@testable import AppsPlusData

class AsynchronousUpdateRequestTest: XCTestCase {
    
    var initialCreateRequest: AsynchronousUpdateRequest<MockEntity>!
    var initialUpdateRequest: AsynchronousUpdateRequest<MockEntity>!
    var initialUpdateOrCreateRequest: AsynchronousUpdateRequest<MockEntity>!
    var failRequest: Bool!
    
    override func setUpWithError() throws {
        initialCreateRequest = AsynchronousUpdateRequest<MockEntity>(publisher: publisher, fetchRequest: .create())
        initialUpdateRequest = AsynchronousUpdateRequest<MockEntity>(publisher: publisher, fetchRequest: .update(orCreate: false))
        initialUpdateOrCreateRequest = AsynchronousUpdateRequest<MockEntity>(publisher: publisher, fetchRequest: .update(orCreate: true))
        failRequest = false
    }
    
    override func tearDownWithError() throws {
        initialCreateRequest = nil
        initialUpdateRequest = nil
        initialUpdateOrCreateRequest = nil
        failRequest = nil
    }
    
    func testSortedAscending_update() {
        [initialUpdateRequest, initialUpdateOrCreateRequest].forEach {
            let request = $0!
                .sorted(by: \.name, ascending: true)
            
            XCTAssertTrue(request.sortDescriptors!.contains(NSSortDescriptor(key: "name", ascending: true)))
        }
    }
    
    func testSortedDescending() {
        [initialUpdateRequest, initialUpdateOrCreateRequest].forEach {
            let request = $0!
                .sorted(by: \.name, ascending: false)
            
            XCTAssertTrue(request.sortDescriptors!.contains(NSSortDescriptor(key: "name", ascending: false)))
        }
    }
    
    func testLimit() {
        [initialUpdateRequest, initialUpdateOrCreateRequest].forEach {
            let request = $0!
                .limit(1)
            XCTAssertEqual(1, request.limit)
        }
    }
    
    func testOffset() {
        [initialUpdateRequest, initialUpdateOrCreateRequest].forEach {
            let request = $0!
                .offset(2)
            XCTAssertEqual(2, request.offset)
        }
    }
    
    func testBatchSize() {
        [initialUpdateRequest, initialUpdateOrCreateRequest].forEach {
            let request = $0!
                .batchSize(3)
            XCTAssertEqual(3, request.batchSize)
        }
    }
    
    func testSuchThat() {
        [initialUpdateRequest, initialUpdateOrCreateRequest].forEach {
            let request = $0!
                .suchThat(predicate: NSPredicate(format: "identifier == 5"))
            XCTAssertEqual(NSPredicate(format: "identifier == 5"), request.predicate)
        }
    }
    
    func testAnd() {
        [initialUpdateRequest, initialUpdateOrCreateRequest].forEach {
            let request = $0!
                .suchThat(predicate: NSPredicate(format: "identifier == 5"))
                .and(predicate: NSPredicate(format: "name == %@", "Name"))
            XCTAssertEqual(NSPredicate(format: "identifier == 5 AND name == 'Name'"), request.predicate)
        }
    }
    
    func testOr() {
        [initialUpdateRequest, initialUpdateOrCreateRequest].forEach {
            let request = $0!
                .suchThat(predicate: NSPredicate(format: "identifier == 5"))
                .or(predicate: NSPredicate(format: "name == %@", "Name"))
            XCTAssertEqual(NSPredicate(format: "identifier == 5 OR name == 'Name'"), request.predicate)
        }
    }
    
    func testExcluding() {
        [initialUpdateRequest, initialUpdateOrCreateRequest].forEach {
            let request = $0!
                .excluding(predicate: NSPredicate(format: "identifier == 5"))
            XCTAssertEqual(NSPredicate(format: "NOT identifier == 5"), request.predicate)
        }
    }
    
    func testSuchThatExcluding() {
        [initialUpdateRequest, initialUpdateOrCreateRequest].forEach {
            let request = $0!
                .suchThat(predicate: NSPredicate(format: "identifier == 5"))
                .excluding(predicate: NSPredicate(format: "name == %@", "Name"))
            XCTAssertEqual(NSPredicate(format: "identifier == 5 AND NOT name == 'Name'"), request.predicate)
        }
    }
    
    func testModify() {
        [initialCreateRequest, initialUpdateRequest, initialUpdateOrCreateRequest].forEach {
            let request = $0!
                .modify {
                    $0.identity = 2
                }
                .modify {
                    $0.name = "2"
                }
            let entity = MockEntity(name: "1", identity: 1)
            request.modifier?(entity, MockSynchronousStorage())
            XCTAssertEqual(2, entity.identity)
            XCTAssertEqual("2", entity.name)
        }
    }
    
    func testPerformSucceeds() {
        [initialCreateRequest, initialUpdateRequest, initialUpdateOrCreateRequest].forEach {
            let expectation = XCTestExpectation()
            
            var succeeded = false
            let _ = $0!
                .perform()
                .sink(receiveCompletion: {
                    if case .finished = $0 {
                        succeeded = true
                    }
                    expectation.fulfill()
                }, receiveValue: { _ in })
            
            wait(for: [expectation], timeout: 1)
            
            XCTAssertTrue(succeeded)
        }
    }
    
    func testPerformFails() {
        [initialCreateRequest, initialUpdateRequest, initialUpdateOrCreateRequest].forEach {
            failRequest = true
            
            let expectation = XCTestExpectation()
            
            var failed = false
            let _ = $0!
                .perform()
                .sink(receiveCompletion: {
                    if case .failure = $0 {
                        failed = true
                    }
                    expectation.fulfill()
                }, receiveValue: { _ in })
            
            wait(for: [expectation], timeout: 1)
            
            XCTAssertTrue(failed)
        }
    }
}

extension AsynchronousUpdateRequestTest {
    
    func publisher(request: AsynchronousUpdateRequest<MockEntity>) -> AnyPublisher<PersistentStoreUpdate, Error> {
        if failRequest {
            return Fail(error: MockError.error).eraseToAnyPublisher()
        } else {
            return Just(MockPersistentStoreUpdate(identifier: "id")).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }
    
}

#endif
