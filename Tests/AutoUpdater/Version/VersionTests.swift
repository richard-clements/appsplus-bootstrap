import XCTest
@testable import AutoUpdater

class VersionTests: XCTestCase {
    
    func testEquality() {
        XCTAssertEqual(Version(major: 1, minor: 2, patch: 3, build: 4), Version(major: 1, minor: 2, patch: 3, build: 4))
        XCTAssertNotEqual(Version(major: 2, minor: 2, patch: 3, build: 4), Version(major: 1, minor: 2, patch: 3, build: 4))
        XCTAssertNotEqual(Version(major: 1, minor: 3, patch: 3, build: 4), Version(major: 1, minor: 2, patch: 3, build: 4))
        XCTAssertNotEqual(Version(major: 1, minor: 2, patch: 4, build: 4), Version(major: 1, minor: 2, patch: 3, build: 4))
        XCTAssertNotEqual(Version(major: 1, minor: 2, patch: 3, build: 5), Version(major: 1, minor: 2, patch: 3, build: 4))
    }
    
    func testLessThan() {
        XCTAssertTrue(Version(major: 1, minor: 2, patch: 3, build: 4) < Version(major: 1, minor: 2, patch: 3, build: 5))
        XCTAssertTrue(Version(major: 1, minor: 2, patch: 3, build: 4) < Version(major: 1, minor: 2, patch: 4, build: 4))
        XCTAssertTrue(Version(major: 1, minor: 2, patch: 3, build: 4) < Version(major: 1, minor: 3, patch: 3, build: 4))
        XCTAssertTrue(Version(major: 1, minor: 2, patch: 3, build: 4) < Version(major: 2, minor: 2, patch: 3, build: 4))
        XCTAssertFalse(Version(major: 1, minor: 2, patch: 3, build: 5) < Version(major: 1, minor: 2, patch: 3, build: 4))
        XCTAssertFalse(Version(major: 1, minor: 2, patch: 4, build: 4) < Version(major: 1, minor: 2, patch: 3, build: 4))
        XCTAssertFalse(Version(major: 1, minor: 3, patch: 3, build: 4) < Version(major: 1, minor: 2, patch: 3, build: 4))
        XCTAssertFalse(Version(major: 2, minor: 2, patch: 3, build: 4) < Version(major: 1, minor: 2, patch: 3, build: 4))
    }
    
}
