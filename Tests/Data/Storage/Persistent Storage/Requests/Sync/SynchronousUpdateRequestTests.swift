#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine
import XCTest
@testable import AppsPlusData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class SynchronousUpdateRequestTest: XCTestCase {
    
    var initialCreateRequest: SynchronousUpdateRequest<MockEntity>!
    var initialUpdateRequest: SynchronousUpdateRequest<MockEntity>!
    var initialUpdateOrCreateRequest: SynchronousUpdateRequest<MockEntity>!
    var failRequest: Bool!
    
    override func setUpWithError() throws {
        initialCreateRequest = SynchronousUpdateRequest<MockEntity>(executor: { _ in }, fetchRequest: .create())
        initialUpdateRequest = SynchronousUpdateRequest<MockEntity>(executor: { _ in }, fetchRequest: .update(orCreate: false))
        initialUpdateOrCreateRequest = SynchronousUpdateRequest<MockEntity>(executor: { _ in }, fetchRequest: .update(orCreate: true))
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
    
}

#endif
