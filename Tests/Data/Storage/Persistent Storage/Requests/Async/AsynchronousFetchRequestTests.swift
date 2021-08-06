#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine
import XCTest
@testable import AppsPlusData

class AsynchronousFetchRequestTest: XCTestCase {
    
    var initialRequest: AsynchronousFetchRequest<MockEntity>!
    var result: [MockEntity]!
    var failRequest: Bool!
    var observedShouldSubscribe: Bool?
    var observedBackgroundScope: AsynchronousFetchRequestBackgroundScope?
    
    override func setUpWithError() throws {
        initialRequest = AsynchronousFetchRequest<MockEntity>(publisher: publisher, fetchRequest: .empty())
        result = []
        failRequest = false
    }
    
    override func tearDownWithError() throws {
        initialRequest = nil
        failRequest = nil
        result = nil
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
        
        result = [MockEntity(name: "1", identity: 1)]
        
        var fetchedResult: [MockEntity]?
        let _ = initialRequest
            .perform()
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: {
                fetchedResult = $0
            })
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertEqual(result, fetchedResult)
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
    
    func testPerform_setSubscribeToFalse() {
        let _ = initialRequest
            .perform()
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        
        XCTAssertEqual(false, observedShouldSubscribe)
    }
    
    func testPerform_setBackgroundScope_nil() {
        let _ = initialRequest
            .perform()
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        
        XCTAssertNil(observedBackgroundScope)
    }
    
    func testPerform_setBackgroundScope_value() {
        let _ = initialRequest
            .perform(inBackgroundScope: "Scope")
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        
        XCTAssertEqual("Scope", observedBackgroundScope)
    }
    
    func testSubscribeSucceeds() {
        let expectation = XCTestExpectation()
        
        result = [MockEntity(name: "1", identity: 1)]
        
        var fetchedResult: [MockEntity]?
        let _ = initialRequest
            .subscribe()
            .sink(receiveCompletion: { _ in
                expectation.fulfill()
            }, receiveValue: {
                fetchedResult = $0
            })
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertEqual(result, fetchedResult)
    }
    
    func testSubscribeFails() {
        failRequest = true
        
        let expectation = XCTestExpectation()
        
        var failed = false
        let _ = initialRequest
            .subscribe()
            .sink(receiveCompletion: {
                if case .failure = $0 {
                    failed = true
                }
                expectation.fulfill()
            }, receiveValue: { _ in })
        
        wait(for: [expectation], timeout: 1)
        
        XCTAssertTrue(failed)
    }
    
    func testSubscribe_setSubscribeToTrue() {
        let _ = initialRequest
            .subscribe()
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        
        XCTAssertEqual(true, observedShouldSubscribe)
    }
    
    func testSubscribe_setBackgroundScope_nil() {
        let _ = initialRequest
            .subscribe()
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        
        XCTAssertNil(observedBackgroundScope)
    }
    
    func testSubscribe_setBackgroundScope_value() {
        let _ = initialRequest
            .subscribe(inBackgroundScope: "Scope")
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
        
        XCTAssertEqual("Scope", observedBackgroundScope)
    }
    
}

extension AsynchronousFetchRequestTest {
    
    func publisher(request: AsynchronousFetchRequest<MockEntity>) -> AnyPublisher<[MockEntity], Error> {
        observedShouldSubscribe = request.shouldSubscribe
        observedBackgroundScope = request.backgroundScope
        if failRequest {
            return Fail(error: MockError.error).eraseToAnyPublisher()
        } else {
            return Just(result).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }
    
}

#endif
