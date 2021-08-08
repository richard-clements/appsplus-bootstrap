#if canImport(Foundation) && canImport(CoreData)

import XCTest
import Foundation
import CoreData
@testable import AppsPlusData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class NSManagedURLFilterTests: XCTestCase {
    
    var urlString: String!
    var url: URL?
    
    override func setUpWithError() throws {
        urlString = "https://www.test.com"
        url = URL(string: urlString)
    }
    
    override func tearDownWithError() throws {
        urlString = nil
        url = nil
    }
    
    func testOptionalURLequalsNil() {
        XCTAssertEqual(NSPredicate(format: "optionalURL == nil"), (\Object.optionalURL == nil).predicate)
    }
    
    func testOptionalURLNotEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "optionalURL != nil"), (\Object.optionalURL != nil).predicate)
    }
    
    func testOptionalURLEqualsURL() {
        XCTAssertEqual(NSPredicate(format: "optionalURL == %@", urlString), (\Object.optionalURL == url).predicate)
    }
    
    func testOptionalURLNotEqualsURL() {
        XCTAssertEqual(NSPredicate(format: "optionalURL != %@", urlString), (\Object.optionalURL != url).predicate)
    }
    
    func testNonOptionalURLEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "url == nil"), (\Object.url == nil).predicate)
    }
    
    func testNonOptionalURLNotEqualsNil() {
        XCTAssertEqual(NSPredicate(format: "url != nil"), (\Object.url != nil).predicate)
    }
    
    func testNonOptionalURLEqualsURL() {
        XCTAssertEqual(NSPredicate(format: "url == %@", urlString), (\Object.url == url).predicate)
    }
    
    func testNonOptionalURLNotEqualsURL() {
        XCTAssertEqual(NSPredicate(format: "url != %@", urlString), (\Object.url != url).predicate)
    }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension NSManagedURLFilterTests {
    
    class Object: NSManagedObject {
        @NSManaged var optionalURL: URL?
        @NSManaged var url: URL
    }
    
}

#endif
