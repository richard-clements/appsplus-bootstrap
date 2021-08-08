#if canImport(Foundation) && canImport(Combine)

import XCTest
import Foundation
import Combine
@testable import AppsPlusData

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class PersistentStorageSaveTests: XCTestCase {
    
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        cancellables = Set()
    }
    
    override func tearDownWithError() throws {
        cancellables = nil
    }
    
    func testSaveWithSameIdentifiersOnlySaveOnce() {
        let updates = Array(repeating: MockUpdate(identifier: "identifier"), count: 10)
        var savesCalled: [Void] = []
        
        let expectation = XCTestExpectation()
        
        updates
            .publisher
            .save()
            .sink { _ in
                expectation.fulfill()
            } receiveValue: {
                savesCalled.append(())
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(1, savesCalled.count)
    }
    
    func testSaveWithDifferentIdentifiersSavesForAll() {
        let updates = (1...10).map { MockUpdate(identifier: $0.description) }
        var savesCalled: [Void] = []
        
        let expectation = XCTestExpectation()
        
        updates
            .publisher
            .save()
            .sink { _ in
                expectation.fulfill()
            } receiveValue: {
                savesCalled.append(())
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(10, savesCalled.count)
    }
    
    func testSaveSucceedsIfAllSucceed() {
        let updates = (1...10).map { MockUpdate(identifier: $0.description) }
        var savesCalled: [Void] = []
        
        let expectation = XCTestExpectation()
        var succeeded = false
        
        updates
            .publisher
            .save()
            .sink {
                expectation.fulfill()
                if case .finished = $0 {
                    succeeded = true
                }
            } receiveValue: {
                savesCalled.append(())
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(succeeded)
    }
    
    func testSaveFailsIfOneFails() {
        let updates = (1...10).map { MockUpdate(identifier: $0.description, shouldFail: $0 == 5) }
        var savesCalled: [Void] = []
        
        let expectation = XCTestExpectation()
        var failed = false
        
        updates
            .publisher
            .save()
            .sink {
                expectation.fulfill()
                if case .failure = $0 {
                    failed = true
                }
            } receiveValue: {
                savesCalled.append(())
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(failed)
    }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension PersistentStorageSaveTests {
    
    struct MockUpdate: PersistentStoreUpdate {
        
        enum MockUpdateError: Error {
            case failed
        }
        
        let identifier: String
        let shouldFail: Bool
        
        init(identifier: String, shouldFail: Bool = false) {
            self.identifier = identifier
            self.shouldFail = shouldFail
        }
        
        func commit() -> AnyPublisher<Void, Error> {
            if shouldFail {
                return Fail(error: MockUpdateError.failed).eraseToAnyPublisher()
            }
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }
    
}

#endif
