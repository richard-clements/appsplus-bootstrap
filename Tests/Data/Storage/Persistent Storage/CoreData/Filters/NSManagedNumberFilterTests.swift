#if canImport(Foundation) && canImport(CoreData)

import XCTest
import Foundation
import CoreData
@testable import AppsPlusData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class NSManagedNumberFilterTests: XCTestCase {
    
    // MARK: Bool
    
    func testBoolEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "bool == nil"), (\Object.bool == nil).predicate)
    }
    
    func testBoolNotEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "bool != nil"), (\Object.bool != nil).predicate)
    }
    
    func testBoolEqualsTrue() {
        XCTAssertEqual(NSPredicate(format: "bool == 1"), (\Object.bool == true).predicate)
    }
    
    func testBoolEqualsFalse() {
        XCTAssertEqual(NSPredicate(format: "bool == 0"), (\Object.bool == false).predicate)
    }
    
    // MARK: Int16
    
    func testInt16EqualsNil() {
        XCTAssertEqual(NSPredicate(format: "int16 == nil"), (\Object.int16 == nil).predicate)
    }
    
    func testInt16NotEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "int16 != nil"), (\Object.int16 != nil).predicate)
    }
    
    func testInt16EqualsValue() {
        XCTAssertEqual(NSPredicate(format: "int16 == 1"), (\Object.int16 == 1).predicate)
    }
    
    func testInt16NotEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "int16 != 1"), (\Object.int16 != 1).predicate)
    }
    
    func testInt16LessThanValue() {
        XCTAssertEqual(NSPredicate(format: "int16 < 1"), (\Object.int16 < 1).predicate)
    }
    
    func testInt16LessThanOrEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "int16 <= 1"), (\Object.int16 <= 1).predicate)
    }
    
    func testInt16GreaterThanValue() {
        XCTAssertEqual(NSPredicate(format: "int16 > 1"), (\Object.int16 > 1).predicate)
    }
    
    func testInt16GreaterThanOrEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "int16 >= 1"), (\Object.int16 >= 1).predicate)
    }
    
    // MARK: Int32
    
    func testInt32EqualsNil() {
        XCTAssertEqual(NSPredicate(format: "int32 == nil"), (\Object.int32 == nil).predicate)
    }
    
    func testInt32NotEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "int32 != nil"), (\Object.int32 != nil).predicate)
    }
    
    func testInt32EqualsValue() {
        XCTAssertEqual(NSPredicate(format: "int32 == 1"), (\Object.int32 == 1).predicate)
    }
    
    func testInt32NotEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "int32 != 1"), (\Object.int32 != 1).predicate)
    }
    
    func testInt32LessThanValue() {
        XCTAssertEqual(NSPredicate(format: "int32 < 1"), (\Object.int32 < 1).predicate)
    }
    
    func testInt32LessThanOrEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "int32 <= 1"), (\Object.int32 <= 1).predicate)
    }
    
    func testInt32GreaterThanValue() {
        XCTAssertEqual(NSPredicate(format: "int32 > 1"), (\Object.int32 > 1).predicate)
    }
    
    func testInt32GreaterThanOrEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "int32 >= 1"), (\Object.int32 >= 1).predicate)
    }
    
    // MARK: Int64
    
    func testInt64EqualsNil() {
        XCTAssertEqual(NSPredicate(format: "int64 == nil"), (\Object.int64 == nil).predicate)
    }
    
    func testInt64NotEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "int64 != nil"), (\Object.int64 != nil).predicate)
    }
    
    func testInt64EqualsValue() {
        XCTAssertEqual(NSPredicate(format: "int64 == 1"), (\Object.int64 == 1).predicate)
    }
    
    func testInt64NotEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "int64 != 1"), (\Object.int64 != 1).predicate)
    }
    
    func testInt64LessThanValue() {
        XCTAssertEqual(NSPredicate(format: "int64 < 1"), (\Object.int64 < 1).predicate)
    }
    
    func testInt64LessThanOrEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "int64 <= 1"), (\Object.int64 <= 1).predicate)
    }
    
    func testInt64GreaterThanValue() {
        XCTAssertEqual(NSPredicate(format: "int64 > 1"), (\Object.int64 > 1).predicate)
    }
    
    func testInt64GreaterThanOrEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "int64 >= 1"), (\Object.int64 >= 1).predicate)
    }
    
    // MARK: Float
    
    func testFloatEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "float == nil"), (\Object.float == nil).predicate)
    }
    
    func testFloatNotEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "float != nil"), (\Object.float != nil).predicate)
    }
    
    func testFloatEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "float == 1"), (\Object.float == 1).predicate)
    }
    
    func testFloatNotEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "float != 1"), (\Object.float != 1).predicate)
    }
    
    func testFloatLessThanValue() {
        XCTAssertEqual(NSPredicate(format: "float < 1"), (\Object.float < 1).predicate)
    }
    
    func testFloatLessThanOrEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "float <= 1"), (\Object.float <= 1).predicate)
    }
    
    func testFloatGreaterThanValue() {
        XCTAssertEqual(NSPredicate(format: "float > 1"), (\Object.float > 1).predicate)
    }
    
    func testFloatGreaterThanOrEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "float >= 1"), (\Object.float >= 1).predicate)
    }
    
    // MARK: Double
    
    func testDoubleEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "double == nil"), (\Object.double == nil).predicate)
    }
    
    func testDoubleNotEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "double != nil"), (\Object.double != nil).predicate)
    }
    
    func testDoubleEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "double == 1"), (\Object.double == 1).predicate)
    }
    
    func testDoubleNotEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "double != 1"), (\Object.double != 1).predicate)
    }
    
    func testDoubleLessThanValue() {
        XCTAssertEqual(NSPredicate(format: "double < 1"), (\Object.double < 1).predicate)
    }
    
    func testDoubleLessThanOrEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "double <= 1"), (\Object.double <= 1).predicate)
    }
    
    func testDoubleGreaterThanValue() {
        XCTAssertEqual(NSPredicate(format: "double > 1"), (\Object.double > 1).predicate)
    }
    
    func testDoubleGreaterThanOrEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "double >= 1"), (\Object.double >= 1).predicate)
    }
    
    // MARK: Number
    
    func testNumberEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "number == nil"), (\Object.number == nil).predicate)
    }
    
    func testNumberNotEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "number != nil"), (\Object.number != nil).predicate)
    }
    
    func testNumberEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "number == 1"), (\Object.number == 1).predicate)
    }
    
    func testNumberNotEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "number != 1"), (\Object.number != 1).predicate)
    }
    
    func testNumberLessThanValue() {
        XCTAssertEqual(NSPredicate(format: "number < 1"), (\Object.number < 1).predicate)
    }
    
    func testNumberLessThanOrEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "number <= 1"), (\Object.number <= 1).predicate)
    }
    
    func testNumberGreaterThanValue() {
        XCTAssertEqual(NSPredicate(format: "number > 1"), (\Object.number > 1).predicate)
    }
    
    func testNumberGreaterThanOrEqualsValue() {
        XCTAssertEqual(NSPredicate(format: "number >= 1"), (\Object.number >= 1).predicate)
    }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension NSManagedNumberFilterTests {
    
    class Object: NSManagedObject {
        @NSManaged var int16: Int16
        @NSManaged var int32: Int32
        @NSManaged var int64: Int64
        @NSManaged var double: Double
        @NSManaged var float: Float
        @NSManaged var bool: Bool
        @NSManaged var number: NSNumber?
    }
    
}

#endif
