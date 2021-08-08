#if canImport(Foundation) && canImport(CoreData)

import XCTest
import Foundation
import CoreData
@testable import AppsPlusData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class NSManagedUUIDFilterTests: XCTestCase {
    
    var uuidString: String!
    var uuid: UUID?
    
    override func setUpWithError() throws {
        uuidString = "E621E1F8-C36C-495A-93FC-0C247A3E6E5F"
        uuid = UUID(uuidString: uuidString)
    }
    
    override func tearDownWithError() throws {
        uuidString = nil
        uuid = nil
    }
    
    func testOptionalUUIDequalsNil() {
        XCTAssertEqual(NSPredicate(format: "optionalUUID == nil"), (\Object.optionalUUID == nil).predicate)
    }
    
    func testOptionalURLNotEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "optionalUUID != nil"), (\Object.optionalUUID != nil).predicate)
    }
    
    func testOptionalUUIDEqualsUUID() {
        XCTAssertEqual(NSPredicate(format: "optionalUUID == %@", uuidString), (\Object.optionalUUID == uuid).predicate)
    }
    
    func testOptionalUUIDNotEqualsUUID() {
        XCTAssertEqual(NSPredicate(format: "optionalUUID != %@", uuidString), (\Object.optionalUUID != uuid).predicate)
    }
    
    func testNonOptionalUUIDEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "uuid == nil"), (\Object.uuid == nil).predicate)
    }
    
    func testNonOptionalUUIDNotEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "uuid != nil"), (\Object.uuid != nil).predicate)
    }
    
    func testNonOptionalUUIDEqualsUUID() {
        XCTAssertEqual(NSPredicate(format: "uuid == %@", uuidString), (\Object.uuid == uuid).predicate)
    }
    
    func testNonOptionalDateNotEqualsDate() {
        XCTAssertEqual(NSPredicate(format: "uuid != %@", uuidString), (\Object.uuid != uuid).predicate)
    }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension NSManagedUUIDFilterTests {
    
    class Object: NSManagedObject {
        @NSManaged var optionalUUID: UUID?
        @NSManaged var uuid: UUID?
    }
    
}

#endif
