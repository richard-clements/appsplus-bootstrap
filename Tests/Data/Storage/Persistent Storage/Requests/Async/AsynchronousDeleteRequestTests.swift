#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine
import XCTest
@testable import AppsPlusData

class AsynchronousDeleteRequestTest: XCTestCase {
    
    var initialRequest: AsynchronousDeleteRequest<MockEntity>!
    var failRequest: Bool!
    
    override func setUpWithError() throws {
        initialRequest = AsynchronousDeleteRequest<MockEntity>(publisher: publisher, fetchRequest: .empty())
        failRequest = false
    }
    
    override func tearDownWithError() throws {
        initialRequest = nil
        failRequest = nil
    }
    
    func testSortedAscending() {
        let request = initialRequest
            .sorted(by: \.name, ascending: true)
        
        XCTAssertTrue(request.sortDescriptors!.contains(NSSortDescriptor(key: "name", ascending: true)))
    }
    
    func testSortedDescending() {
        let request = initialRequest
            .sorted(by: \.name, ascending: false)
        
        XCTAssertTrue(request.sortDescriptors!.contains(NSSortDescriptor(key: "name", ascending: false)))
    }
    
    func testLimit() {
        let request = initialRequest
            .limit(1)
        XCTAssertEqual(1, request.limit)
    }
    
    func testOffset() {
        let request = initialRequest
            .offset(2)
        XCTAssertEqual(2, request.offset)
    }
    
    func testBatchSize() {
        let request = initialRequest
            .batchSize(3)
        XCTAssertEqual(3, request.batchSize)
    }
    
    func testSuchThat() {
        let request = initialRequest
            .suchThat(predicate: NSPredicate(format: "identifier == 5"))
        XCTAssertEqual(NSPredicate(format: "identifier == 5"), request.predicate)
    }
    
    func testAnd() {
        let request = initialRequest
            .suchThat(predicate: NSPredicate(format: "identifier == 5"))
            .and(predicate: NSPredicate(format: "name == %@", "Name"))
        XCTAssertEqual(NSPredicate(format: "identifier == 5 AND name == 'Name'"), request.predicate)
    }
    
    func testOr() {
        let request = initialRequest
            .suchThat(predicate: NSPredicate(format: "identifier == 5"))
            .or(predicate: NSPredicate(format: "name == %@", "Name"))
        XCTAssertEqual(NSPredicate(format: "identifier == 5 OR name == 'Name'"), request.predicate)
    }
    
    func testExcluding() {
        let request = initialRequest
            .excluding(predicate: NSPredicate(format: "identifier == 5"))
        XCTAssertEqual(NSPredicate(format: "NOT identifier == 5"), request.predicate)
    }
    
    func testSuchThatExcluding() {
        let request = initialRequest
            .suchThat(predicate: NSPredicate(format: "identifier == 5"))
            .excluding(predicate: NSPredicate(format: "name == %@", "Name"))
        XCTAssertEqual(NSPredicate(format: "identifier == 5 AND NOT name == 'Name'"), request.predicate)
    }
    
    func testPerformSucceeds() {
        let expectation = XCTestExpectation()
        
        var succeeded = false
        let _ = initialRequest
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
    
    func testPerformFails() {
        failRequest = true
        
        let expectation = XCTestExpectation()
        
        var failed = false
        let _ = initialRequest
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

extension AsynchronousDeleteRequestTest {
    
    func publisher(request: AsynchronousDeleteRequest<MockEntity>) -> AnyPublisher<PersistentStoreUpdate, Error> {
        if failRequest {
            return Fail(error: MockError.error).eraseToAnyPublisher()
        } else {
            return Just(MockPersistentStoreUpdate(identifier: "id")).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }
    
}

#endif
