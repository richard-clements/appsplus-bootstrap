#if canImport(Foundation)

import Foundation
import XCTest
@testable import AppsPlusData

class SynchronousDeleteRequestTest: XCTestCase {
    
    var initialRequest: SynchronousDeleteRequest<MockEntity>!
    
    override func setUpWithError() throws {
        initialRequest = SynchronousDeleteRequest<MockEntity>(executor: { _ in }, fetchRequest: .empty())
    }
    
    override func tearDownWithError() throws {
        initialRequest = nil
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
    
}


#endif
