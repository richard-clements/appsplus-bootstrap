import XCTest
@testable import AppsPlusData

class ValidationErrorTests: XCTestCase {
    
    func test_validationErrorThrows_ifMissingErrors() {
        let data = """
        {
            "error": "This is an invalid error"
        }
        """.data(using: .utf8)!
        XCTAssertThrowsError(try ValidationError<MockField>(data: data))
    }
    
    func test_validationError_valid() {
        let data = """
        {
            "errors": {
                "field1": [
                    "Field 1 error 1",
                    "Field 1 error 2"
                ],
                "field2": [
                    "Field 2 error 1",
                    "Field 2 error 2"
                ]
            }
        }
        """.data(using: .utf8)!
        
        let validationError = try? ValidationError<MockField>(data: data)
        XCTAssertEqual([
            "Field 1 error 1",
            "Field 1 error 2"
        ], validationError?.errors[.field1])
        
        XCTAssertEqual([
            "Field 2 error 1",
            "Field 2 error 2"
        ], validationError?.errors[.field2])
    }
    
    func test_validationError_noErrors_throws() {
        let data = """
        {
            "errors": {
                "field1": [],
                "field2": []
            }
        }
        """.data(using: .utf8)!
        
        XCTAssertThrowsError(try ValidationError<MockField>(data: data))
    }
}

extension ValidationErrorTests {
    
    enum MockField: String, CaseIterable, Hashable {
        case field1
        case field2
    }
    
}
