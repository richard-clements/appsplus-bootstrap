#if canImport(Foundation) && canImport(CoreData)

import XCTest
import Foundation
import CoreData
@testable import AppsPlusData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class NSManagedStringFilterTests: XCTestCase {
    
    func testOptionalStringEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "optionalString == nil"), (\Object.optionalString == nil).predicate)
    }
    
    func testOptionalStringNotEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "optionalString != nil"), (\Object.optionalString != nil).predicate)
    }
    
    func testOptionalStringEqualsString() {
        XCTAssertEqual(NSPredicate(format: "optionalString == %@", "Test"), (\Object.optionalString == "Test").predicate)
    }
    
    func testOptionalUUIDNotEqualsUUID() {
        XCTAssertEqual(NSPredicate(format: "optionalString != %@", "Test"), (\Object.optionalString != "Test").predicate)
    }
    
    func testNonOptionalStringEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "string == nil"), (\Object.string == nil).predicate)
    }
    
    func testNonOptionalStringNotEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "string != nil"), (\Object.string != nil).predicate)
    }
    
    func testNonOptionalStringEqualsString() {
        XCTAssertEqual(NSPredicate(format: "string == %@", "Test"), (\Object.string == "Test").predicate)
    }
    
    func testNonOptionalUUIDNotEqualsUUID() {
        XCTAssertEqual(NSPredicate(format: "string != %@", "Test"), (\Object.string != "Test").predicate)
    }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension NSManagedStringFilterTests {
    
    class Object: NSManagedObject {
        @NSManaged var optionalString: String?
        @NSManaged var string: String?
    }
    
}

#endif
