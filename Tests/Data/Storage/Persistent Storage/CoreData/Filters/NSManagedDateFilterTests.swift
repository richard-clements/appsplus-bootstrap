#if canImport(Foundation) && canImport(CoreData)

import XCTest
import Foundation
import CoreData
@testable import AppsPlusData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class NSManagedDateFilterTests: XCTestCase {
    
//    func testOptionalDateEqualsNil() {
//        XCTAssertEqual(NSPredicate(format: "optionalDate == nil"), (\Object.optionalDate == nil).predicate)
//    }
//    
//    func testOptionalDateNotEqualsNil() {
//        XCTAssertEqual(NSPredicate(format: "optionalDate != nil"), (\Object.optionalDate != nil).predicate)
//    }
//    
//    func testOptionalDateEqualsDate() {
//        XCTAssertEqual(NSPredicate(format: "optionalDate == %@", Date(timeIntervalSince1970: 1234567890) as NSDate), (\Object.optionalDate == Date(timeIntervalSince1970: 1234567890)).predicate)
//    }
//    
//    func testOptionalDateNotEqualsDate() {
//        XCTAssertEqual(NSPredicate(format: "optionalDate != %@", Date(timeIntervalSince1970: 1234567890) as NSDate), (\Object.optionalDate != Date(timeIntervalSince1970: 1234567890)).predicate)
//    }
//    
//    func testOptionalDateLessThanDate() {
//        XCTAssertEqual(NSPredicate(format: "optionalDate < %@", Date(timeIntervalSince1970: 1234567890) as NSDate), (\Object.optionalDate < Date(timeIntervalSince1970: 1234567890)).predicate)
//    }
//    
//    func testOptionalDateLessThanOrEqualDate() {
//        XCTAssertEqual(NSPredicate(format: "optionalDate <= %@", Date(timeIntervalSince1970: 1234567890) as NSDate), (\Object.optionalDate <= Date(timeIntervalSince1970: 1234567890)).predicate)
//    }
//    
//    func testOptionalDateGreaterThanDate() {
//        XCTAssertEqual(NSPredicate(format: "optionalDate > %@", Date(timeIntervalSince1970: 1234567890) as NSDate), (\Object.optionalDate > Date(timeIntervalSince1970: 1234567890)).predicate)
//    }
//    
//    func testOptionalDateGreaterThanOrEqualDate() {
//        XCTAssertEqual(NSPredicate(format: "optionalDate >= %@", Date(timeIntervalSince1970: 1234567890) as NSDate), (\Object.optionalDate >= Date(timeIntervalSince1970: 1234567890)).predicate)
//    }
//    
//    func testNonOptionalDateEqualsNil() {
//        XCTAssertEqual(NSPredicate(format: "date == nil"), (\Object.date == nil).predicate)
//    }
//    
//    func testNonOptionalDateNotEqualsNil() {
//        XCTAssertEqual(NSPredicate(format: "date != nil"), (\Object.date != nil).predicate)
//    }
//    
//    func testNonOptionalDateEqualsDate() {
//        XCTAssertEqual(NSPredicate(format: "date == %@", Date(timeIntervalSince1970: 1234567890) as NSDate), (\Object.date == Date(timeIntervalSince1970: 1234567890)).predicate)
//    }
//    
//    func testNonOptionalDateNotEqualsDate() {
//        XCTAssertEqual(NSPredicate(format: "date != %@", Date(timeIntervalSince1970: 1234567890) as NSDate), (\Object.date != Date(timeIntervalSince1970: 1234567890)).predicate)
//    }
//    
//    func testNonOptionalDateLessThanDate() {
//        XCTAssertEqual(NSPredicate(format: "date < %@", Date(timeIntervalSince1970: 1234567890) as NSDate), (\Object.date < Date(timeIntervalSince1970: 1234567890)).predicate)
//    }
//    
//    func testNonOptionalDateLessThanOrEqualDate() {
//        XCTAssertEqual(NSPredicate(format: "date <= %@", Date(timeIntervalSince1970: 1234567890) as NSDate), (\Object.date <= Date(timeIntervalSince1970: 1234567890)).predicate)
//    }
//    
//    func testNonOptionalDateGreaterThanDate() {
//        XCTAssertEqual(NSPredicate(format: "date > %@", Date(timeIntervalSince1970: 1234567890) as NSDate), (\Object.date > Date(timeIntervalSince1970: 1234567890)).predicate)
//    }
//    
//    func testNonOptionalDateGreaterThanOrEqualDate() {
//        XCTAssertEqual(NSPredicate(format: "date >= %@", Date(timeIntervalSince1970: 1234567890) as NSDate), (\Object.date >= Date(timeIntervalSince1970: 1234567890)).predicate)
//    }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension NSManagedDateFilterTests {
    
    class Object: NSManagedObject {
        @NSManaged var optionalDate: Date?
        @NSManaged var date: Date
    }
    
}

#endif
