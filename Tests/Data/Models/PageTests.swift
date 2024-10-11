import XCTest
@testable import AppsPlusData

class PageTests: XCTestCase {
    
    func testMap() {
        let page = Page(data: [1, 2, 3, 4, 5], meta: .init(currentPage: 1, lastPage: 3, total: nil))
        let newPage = page.map(\.description)
        XCTAssertEqual(["1", "2", "3", "4", "5"], newPage.data)
        XCTAssertEqual(1, page.meta.currentPage)
        XCTAssertEqual(3, page.meta.lastPage)
    }
    
    func testCompactMap() {
        let page = Page(data: [1, 2, 3, 4, 5], meta: .init(currentPage: 1, lastPage: 3, total: nil))
        let newPage = page.compactMap { (value) -> String? in
            if value % 2 == 0 {
                return value.description
            }
            return nil
        }
        XCTAssertEqual(["2", "4"], newPage.data)
        XCTAssertEqual(1, page.meta.currentPage)
        XCTAssertEqual(3, page.meta.lastPage)
    }
    
    func testFlatMap() {
        let page = Page(data: [[1], [2, 2], [3, 3, 3], [4, 4, 4, 4], [5, 5, 5, 5, 5]], meta: .init(currentPage: 1, lastPage: 3, total: nil))
        let newPage = page.flatMap { $0.map { $0 + 1 } }
        XCTAssertEqual([2, 3, 3, 4, 4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 6], newPage.data)
        XCTAssertEqual(1, page.meta.currentPage)
        XCTAssertEqual(3, page.meta.lastPage)
    }
    
    func testIsLastPage() {
        XCTAssertTrue(Page(data: [String](), meta: .init(currentPage: 2, lastPage: 2, total: nil)).isLastPage)
        XCTAssertTrue(Page(data: [String](), meta: .init(currentPage: 3, lastPage: 2, total: nil)).isLastPage)
        XCTAssertFalse(Page(data: [String](), meta: .init(currentPage: 1, lastPage: 2, total: nil)).isLastPage)
    }
    
    func testHasNextPage() {
        XCTAssertTrue(Page(data: [String](), meta: .init(currentPage: 1, lastPage: 2, total: nil)).hasNextPage)
        XCTAssertFalse(Page(data: [String](), meta: .init(currentPage: 2, lastPage: 2, total: nil)).hasNextPage)
    }
    
    
}
