import XCTest
@testable import AppsPlusData

class PageTests: XCTestCase {
    
    func testMap() {
        let page = Page(data: [1, 2, 3, 4, 5], meta: .init(currentPage: 1, lastPage: 3))
        let newPage = page.map(\.description)
        XCTAssertEqual(["1", "2", "3", "4", "5"], newPage.data)
        XCTAssertEqual(1, page.meta.currentPage)
        XCTAssertEqual(3, page.meta.lastPage)
    }
    
}
