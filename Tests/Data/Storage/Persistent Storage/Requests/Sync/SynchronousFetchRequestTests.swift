#if canImport(Foundation)

import Foundation
import XCTest
@testable import AppsPlusData

class SynchronousFetchRequestTest: XCTestCase {
    
    var initialRequest: SynchronousFetchRequest<MockEntity>!
    var result: [MockEntity]!
    
    override func setUpWithError() throws {
        initialRequest = SynchronousFetchRequest<MockEntity>(executor: { [unowned self] _ in result }, fetchRequest: .empty())
        result = []
    }
    
    override func tearDownWithError() throws {
        initialRequest = nil
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
    
    func testPerformReturnsResult() {
        result = [MockEntity(name: "1", identity: 1)]
        XCTAssertEqual(result, initialRequest.perform())
    }
}


#endif
