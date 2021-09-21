#if canImport(Foundation) && canImport(CoreData) && canImport(Combine)

import XCTest
import Foundation
import CoreData
@testable import AppsPlusData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class NSManagedFilterRequestTests: XCTestCase {
    
    func testSuchThatKeyPathFilter() {
        let request = MockFilterRequest<Object>()
            .suchThat { \.string == "Test" }
        XCTAssertEqual(
            [NSPredicate(format: "string == 'Test'")],
            request.suchThatPredicates
        )
    }
    
    func testAndKeyPathFilter() {
        let request = MockFilterRequest<Object>()
            .and { \.string == "Test" }
        XCTAssertEqual(
            [NSPredicate(format: "string == 'Test'")],
            request.andPredicates
        )
    }
    
    func testOrKeyPathFilter() {
        let request = MockFilterRequest<Object>()
            .or { \.string == "Test" }
        XCTAssertEqual(
            [NSPredicate(format: "string == 'Test'")],
            request.orPredicates
        )
    }
    
    func testExcludingKeyPathFilter() {
        let request = MockFilterRequest<Object>()
            .excluding { \.string == "Test" }
        XCTAssertEqual(
            [NSPredicate(format: "string == 'Test'")],
            request.excludingPredicates
        )
    }
    
    func testSuchThatContainedInArrayOptional() {
        let request = MockFilterRequest<Object>()
            .suchThat(\.string, containedIn: ["Test", nil])
        XCTAssertEqual(
            [NSPredicate(format: "string IN %@", ["Test", nil])],
            request.suchThatPredicates
        )
    }
    
    func testAndContainedInArrayOptional() {
        let request = MockFilterRequest<Object>()
            .and(\.string, containedIn: ["Test", nil])
        XCTAssertEqual(
            [NSPredicate(format: "string IN %@", ["Test", nil])],
            request.andPredicates
        )
    }
    
    func testOrContainedInArrayOptional() {
        let request = MockFilterRequest<Object>()
            .or(\.string, containedIn: ["Test", nil])
        XCTAssertEqual(
            [NSPredicate(format: "string IN %@", ["Test", nil])],
            request.orPredicates
        )
    }
    
    func testExcludingContainedInArrayOptional() {
        let request = MockFilterRequest<Object>()
            .excluding(\.string, containedIn: ["Test", nil])
        XCTAssertEqual(
            [NSPredicate(format: "string IN %@", ["Test", nil])],
            request.excludingPredicates
        )
    }
    
    func testSuchThatContainedInArrayNonOptional() {
        let request = MockFilterRequest<Object>()
            .suchThat(\.integer, containedIn: [1, 2])
        XCTAssertEqual(
            [NSPredicate(format: "integer IN %@", [NSNumber(value: 1), NSNumber(value: 2)])],
            request.suchThatPredicates
        )
    }
    
    func testAndContainedInArrayNonOptional() {
        let request = MockFilterRequest<Object>()
            .and(\.integer, containedIn: [1, 2])
        XCTAssertEqual(
            [NSPredicate(format: "integer IN %@", [NSNumber(value: 1), NSNumber(value: 2)])],
            request.andPredicates
        )
    }
    
    func testOrContainedInArrayNonOptional() {
        let request = MockFilterRequest<Object>()
            .or(\.integer, containedIn: [1, 2])
        XCTAssertEqual(
            [NSPredicate(format: "integer IN %@", [NSNumber(value: 1), NSNumber(value: 2)])],
            request.orPredicates
        )
    }
    
    func testExcludingContainedInArrayNonOptional() {
        let request = MockFilterRequest<Object>()
            .excluding(\.integer, containedIn: [1, 2])
        XCTAssertEqual(
            [NSPredicate(format: "integer IN %@", [NSNumber(value: 1), NSNumber(value: 2)])],
            request.excludingPredicates
        )
    }
    
    func testSuchThatStringLike() {
        let request = MockFilterRequest<Object>()
            .suchThat(\.string, like: "String")
            .suchThat(\.string, like: "String", options: [.caseInsensitive])
            .suchThat(\.string, like: "String", options: [.diacriticInsensitive])
            .suchThat(\.string, like: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string LIKE 'String'"),
                NSPredicate(format: "string LIKE[c] 'String'"),
                NSPredicate(format: "string LIKE[d] 'String'"),
                NSPredicate(format: "string LIKE[cd] 'String'"),
            ],
            request.suchThatPredicates
        )
    }
    
    func testSuchThatStringContains() {
        let request = MockFilterRequest<Object>()
            .suchThat(\.string, contains: "String")
            .suchThat(\.string, contains: "String", options: [.caseInsensitive])
            .suchThat(\.string, contains: "String", options: [.diacriticInsensitive])
            .suchThat(\.string, contains: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string CONTAINS 'String'"),
                NSPredicate(format: "string CONTAINS[c] 'String'"),
                NSPredicate(format: "string CONTAINS[d] 'String'"),
                NSPredicate(format: "string CONTAINS[cd] 'String'"),
            ],
            request.suchThatPredicates
        )
    }
    
    func testSuchThatStringBeginsWith() {
        let request = MockFilterRequest<Object>()
            .suchThat(\.string, beginsWith: "String")
            .suchThat(\.string, beginsWith: "String", options: [.caseInsensitive])
            .suchThat(\.string, beginsWith: "String", options: [.diacriticInsensitive])
            .suchThat(\.string, beginsWith: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string BEGINSWITH 'String'"),
                NSPredicate(format: "string BEGINSWITH[c] 'String'"),
                NSPredicate(format: "string BEGINSWITH[d] 'String'"),
                NSPredicate(format: "string BEGINSWITH[cd] 'String'"),
            ],
            request.suchThatPredicates
        )
    }
    
    func testSuchThatStringEndsWith() {
        let request = MockFilterRequest<Object>()
            .suchThat(\.string, endsWith: "String")
            .suchThat(\.string, endsWith: "String", options: [.caseInsensitive])
            .suchThat(\.string, endsWith: "String", options: [.diacriticInsensitive])
            .suchThat(\.string, endsWith: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string ENDSWITH 'String'"),
                NSPredicate(format: "string ENDSWITH[c] 'String'"),
                NSPredicate(format: "string ENDSWITH[d] 'String'"),
                NSPredicate(format: "string ENDSWITH[cd] 'String'"),
            ],
            request.suchThatPredicates
        )
    }
    
    func testSuchThatStringMatches() {
        let request = MockFilterRequest<Object>()
            .suchThat(\.string, matches: "String")
            .suchThat(\.string, matches: "String", options: [.caseInsensitive])
            .suchThat(\.string, matches: "String", options: [.diacriticInsensitive])
            .suchThat(\.string, matches: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string MATCHES 'String'"),
                NSPredicate(format: "string MATCHES[c] 'String'"),
                NSPredicate(format: "string MATCHES[d] 'String'"),
                NSPredicate(format: "string MATCHES[cd] 'String'"),
            ],
            request.suchThatPredicates
        )
    }
    
    func testOrStringLike() {
        let request = MockFilterRequest<Object>()
            .or(\.string, like: "String")
            .or(\.string, like: "String", options: [.caseInsensitive])
            .or(\.string, like: "String", options: [.diacriticInsensitive])
            .or(\.string, like: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string LIKE 'String'"),
                NSPredicate(format: "string LIKE[c] 'String'"),
                NSPredicate(format: "string LIKE[d] 'String'"),
                NSPredicate(format: "string LIKE[cd] 'String'"),
            ],
            request.orPredicates
        )
    }
    
    func testOrStringContains() {
        let request = MockFilterRequest<Object>()
            .or(\.string, contains: "String")
            .or(\.string, contains: "String", options: [.caseInsensitive])
            .or(\.string, contains: "String", options: [.diacriticInsensitive])
            .or(\.string, contains: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string CONTAINS 'String'"),
                NSPredicate(format: "string CONTAINS[c] 'String'"),
                NSPredicate(format: "string CONTAINS[d] 'String'"),
                NSPredicate(format: "string CONTAINS[cd] 'String'"),
            ],
            request.orPredicates
        )
    }
    
    func testOrStringBeginsWith() {
        let request = MockFilterRequest<Object>()
            .or(\.string, beginsWith: "String")
            .or(\.string, beginsWith: "String", options: [.caseInsensitive])
            .or(\.string, beginsWith: "String", options: [.diacriticInsensitive])
            .or(\.string, beginsWith: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string BEGINSWITH 'String'"),
                NSPredicate(format: "string BEGINSWITH[c] 'String'"),
                NSPredicate(format: "string BEGINSWITH[d] 'String'"),
                NSPredicate(format: "string BEGINSWITH[cd] 'String'"),
            ],
            request.orPredicates
        )
    }
    
    func testOrStringEndsWith() {
        let request = MockFilterRequest<Object>()
            .or(\.string, endsWith: "String")
            .or(\.string, endsWith: "String", options: [.caseInsensitive])
            .or(\.string, endsWith: "String", options: [.diacriticInsensitive])
            .or(\.string, endsWith: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string ENDSWITH 'String'"),
                NSPredicate(format: "string ENDSWITH[c] 'String'"),
                NSPredicate(format: "string ENDSWITH[d] 'String'"),
                NSPredicate(format: "string ENDSWITH[cd] 'String'"),
            ],
            request.orPredicates
        )
    }
    
    func testOrStringMatches() {
        let request = MockFilterRequest<Object>()
            .or(\.string, matches: "String")
            .or(\.string, matches: "String", options: [.caseInsensitive])
            .or(\.string, matches: "String", options: [.diacriticInsensitive])
            .or(\.string, matches: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string MATCHES 'String'"),
                NSPredicate(format: "string MATCHES[c] 'String'"),
                NSPredicate(format: "string MATCHES[d] 'String'"),
                NSPredicate(format: "string MATCHES[cd] 'String'"),
            ],
            request.orPredicates
        )
    }
    
    func testAndStringLike() {
        let request = MockFilterRequest<Object>()
            .and(\.string, like: "String")
            .and(\.string, like: "String", options: [.caseInsensitive])
            .and(\.string, like: "String", options: [.diacriticInsensitive])
            .and(\.string, like: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string LIKE 'String'"),
                NSPredicate(format: "string LIKE[c] 'String'"),
                NSPredicate(format: "string LIKE[d] 'String'"),
                NSPredicate(format: "string LIKE[cd] 'String'"),
            ],
            request.andPredicates
        )
    }
    
    func testAndStringContains() {
        let request = MockFilterRequest<Object>()
            .and(\.string, contains: "String")
            .and(\.string, contains: "String", options: [.caseInsensitive])
            .and(\.string, contains: "String", options: [.diacriticInsensitive])
            .and(\.string, contains: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string CONTAINS 'String'"),
                NSPredicate(format: "string CONTAINS[c] 'String'"),
                NSPredicate(format: "string CONTAINS[d] 'String'"),
                NSPredicate(format: "string CONTAINS[cd] 'String'"),
            ],
            request.andPredicates
        )
    }
    
    func testAndStringBeginsWith() {
        let request = MockFilterRequest<Object>()
            .and(\.string, beginsWith: "String")
            .and(\.string, beginsWith: "String", options: [.caseInsensitive])
            .and(\.string, beginsWith: "String", options: [.diacriticInsensitive])
            .and(\.string, beginsWith: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string BEGINSWITH 'String'"),
                NSPredicate(format: "string BEGINSWITH[c] 'String'"),
                NSPredicate(format: "string BEGINSWITH[d] 'String'"),
                NSPredicate(format: "string BEGINSWITH[cd] 'String'"),
            ],
            request.andPredicates
        )
    }
    
    func testAndStringEndsWith() {
        let request = MockFilterRequest<Object>()
            .and(\.string, endsWith: "String")
            .and(\.string, endsWith: "String", options: [.caseInsensitive])
            .and(\.string, endsWith: "String", options: [.diacriticInsensitive])
            .and(\.string, endsWith: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string ENDSWITH 'String'"),
                NSPredicate(format: "string ENDSWITH[c] 'String'"),
                NSPredicate(format: "string ENDSWITH[d] 'String'"),
                NSPredicate(format: "string ENDSWITH[cd] 'String'"),
            ],
            request.andPredicates
        )
    }
    
    func testAndStringMatches() {
        let request = MockFilterRequest<Object>()
            .and(\.string, matches: "String")
            .and(\.string, matches: "String", options: [.caseInsensitive])
            .and(\.string, matches: "String", options: [.diacriticInsensitive])
            .and(\.string, matches: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string MATCHES 'String'"),
                NSPredicate(format: "string MATCHES[c] 'String'"),
                NSPredicate(format: "string MATCHES[d] 'String'"),
                NSPredicate(format: "string MATCHES[cd] 'String'"),
            ],
            request.andPredicates
        )
    }
    
    func testExcludingStringLike() {
        let request = MockFilterRequest<Object>()
            .excluding(\.string, like: "String")
            .excluding(\.string, like: "String", options: [.caseInsensitive])
            .excluding(\.string, like: "String", options: [.diacriticInsensitive])
            .excluding(\.string, like: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string LIKE 'String'"),
                NSPredicate(format: "string LIKE[c] 'String'"),
                NSPredicate(format: "string LIKE[d] 'String'"),
                NSPredicate(format: "string LIKE[cd] 'String'"),
            ],
            request.excludingPredicates
        )
    }
    
    func testExcludingStringContains() {
        let request = MockFilterRequest<Object>()
            .excluding(\.string, contains: "String")
            .excluding(\.string, contains: "String", options: [.caseInsensitive])
            .excluding(\.string, contains: "String", options: [.diacriticInsensitive])
            .excluding(\.string, contains: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string CONTAINS 'String'"),
                NSPredicate(format: "string CONTAINS[c] 'String'"),
                NSPredicate(format: "string CONTAINS[d] 'String'"),
                NSPredicate(format: "string CONTAINS[cd] 'String'"),
            ],
            request.excludingPredicates
        )
    }
    
    func testExcludingStringBeginsWith() {
        let request = MockFilterRequest<Object>()
            .excluding(\.string, beginsWith: "String")
            .excluding(\.string, beginsWith: "String", options: [.caseInsensitive])
            .excluding(\.string, beginsWith: "String", options: [.diacriticInsensitive])
            .excluding(\.string, beginsWith: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string BEGINSWITH 'String'"),
                NSPredicate(format: "string BEGINSWITH[c] 'String'"),
                NSPredicate(format: "string BEGINSWITH[d] 'String'"),
                NSPredicate(format: "string BEGINSWITH[cd] 'String'"),
            ],
            request.excludingPredicates
        )
    }
    
    func testExcludingStringEndsWith() {
        let request = MockFilterRequest<Object>()
            .excluding(\.string, endsWith: "String")
            .excluding(\.string, endsWith: "String", options: [.caseInsensitive])
            .excluding(\.string, endsWith: "String", options: [.diacriticInsensitive])
            .excluding(\.string, endsWith: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string ENDSWITH 'String'"),
                NSPredicate(format: "string ENDSWITH[c] 'String'"),
                NSPredicate(format: "string ENDSWITH[d] 'String'"),
                NSPredicate(format: "string ENDSWITH[cd] 'String'"),
            ],
            request.excludingPredicates
        )
    }
    
    func testExcludingStringMatches() {
        let request = MockFilterRequest<Object>()
            .excluding(\.string, matches: "String")
            .excluding(\.string, matches: "String", options: [.caseInsensitive])
            .excluding(\.string, matches: "String", options: [.diacriticInsensitive])
            .excluding(\.string, matches: "String", options: [.caseInsensitive, .diacriticInsensitive])
        XCTAssertEqual(
            [
                NSPredicate(format: "string MATCHES 'String'"),
                NSPredicate(format: "string MATCHES[c] 'String'"),
                NSPredicate(format: "string MATCHES[d] 'String'"),
                NSPredicate(format: "string MATCHES[cd] 'String'"),
            ],
            request.excludingPredicates
        )
    }
    
    func testExcludingIsNil() {
        let request = MockFilterRequest<Object>()
            .excluding(isNil: \.string)
        XCTAssertEqual([NSPredicate(format: "string == nil")], request.excludingPredicates)
    }
    
    func testExcludingIsNotNil() {
        let request = MockFilterRequest<Object>()
            .excluding(isNotNil: \.string)
        XCTAssertEqual([NSPredicate(format: "string != nil")], request.excludingPredicates)
    }
    
    func testSuchThatIsNil() {
        let request = MockFilterRequest<Object>()
            .suchThat(isNil: \.string)
        XCTAssertEqual([NSPredicate(format: "string == nil")], request.suchThatPredicates)
    }
    
    func testSuchThatIsNotNil() {
        let request = MockFilterRequest<Object>()
            .suchThat(isNotNil: \.string)
        XCTAssertEqual([NSPredicate(format: "string != nil")], request.suchThatPredicates)
    }
    
    func testAndIsNil() {
        let request = MockFilterRequest<Object>()
            .and(isNil: \.string)
        XCTAssertEqual([NSPredicate(format: "string == nil")], request.andPredicates)
    }
    
    func testAndIsNotNil() {
        let request = MockFilterRequest<Object>()
            .and(isNotNil: \.string)
        XCTAssertEqual([NSPredicate(format: "string != nil")], request.andPredicates)
    }
    
    func testOrIsNil() {
        let request = MockFilterRequest<Object>()
            .or(isNil: \.string)
        XCTAssertEqual([NSPredicate(format: "string == nil")], request.orPredicates)
    }
    
    func testOrIsNotNil() {
        let request = MockFilterRequest<Object>()
            .or(isNotNil: \.string)
        XCTAssertEqual([NSPredicate(format: "string != nil")], request.orPredicates)
    }
    
    func testExludingIsEmptyOrNil() {
        let request = MockFilterRequest<Object>()
            .excluding(isEmpty: \.nullableSet)
        XCTAssertEqual([NSPredicate(format: "nullableSet.@count == 0")], request.excludingPredicates)
    }
    
    func testExludingIsEmpty() {
        let request = MockFilterRequest<Object>()
            .excluding(isEmpty: \.nonNullableSet)
        XCTAssertEqual([NSPredicate(format: "nonNullableSet.@count == 0")], request.excludingPredicates)
    }
    
    func testSuchThatIsEmptyOrNil() {
        let request = MockFilterRequest<Object>()
            .suchThat(isEmpty: \.nullableSet)
        XCTAssertEqual([NSPredicate(format: "nullableSet.@count == 0")], request.suchThatPredicates)
    }
    
    func testSuchThatIsEmpty() {
        let request = MockFilterRequest<Object>()
            .suchThat(isEmpty: \.nonNullableSet)
        XCTAssertEqual([NSPredicate(format: "nonNullableSet.@count == 0")], request.suchThatPredicates)
    }
    
    func testAndIsEmptyOrNil() {
        let request = MockFilterRequest<Object>()
            .and(isEmpty: \.nullableSet)
        XCTAssertEqual([NSPredicate(format: "nullableSet.@count == 0")], request.andPredicates)
    }
    
    func testAndIsEmpty() {
        let request = MockFilterRequest<Object>()
            .and(isEmpty: \.nonNullableSet)
        XCTAssertEqual([NSPredicate(format: "nonNullableSet.@count == 0")], request.andPredicates)
    }
    
    func testOrIsEmptyOrNil() {
        let request = MockFilterRequest<Object>()
            .or(isEmpty: \.nullableSet)
        XCTAssertEqual([NSPredicate(format: "nullableSet.@count == 0")], request.orPredicates)
    }
    
    func testOrIsEmpty() {
        let request = MockFilterRequest<Object>()
            .or(isEmpty: \.nonNullableSet)
        XCTAssertEqual([NSPredicate(format: "nonNullableSet.@count == 0")], request.orPredicates)
    }
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension NSManagedFilterRequestTests {
    
    class Object: NSManagedObject {
        @NSManaged var integer: Int32
        @NSManaged var string: String?
        @NSManaged var nullableSet: NSSet?
        @NSManaged var nonNullableSet: NSSet
    }
    
}

#endif
