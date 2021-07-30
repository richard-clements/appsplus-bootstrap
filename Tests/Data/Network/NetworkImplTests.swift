#if canImport(XCTest) && canImport(Combine)

import XCTest
import Combine
@testable import AppsPlus

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class NetworkerImplTests: XCTestCase {
    
    var session: URLSession!
    var networker: NetworkerImpl!
    var authenticator: MockAuthenticator!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        MockNetworkProtocol.setUpForTests()
        session = URLSession.mock
        authenticator = MockAuthenticator()
        networker = NetworkerImpl(session: session, authenticator: authenticator)
        cancellables = Set()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        MockNetworkProtocol.tearDownForTests()
        authenticator = nil
        session = nil
        networker = nil
        cancellables = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testRequestFailsWithNotAuthenticated_WhenAuthenticatorReturnsNoAuthSession() {
        let expectation = XCTestExpectation()
        
        authenticator.authenticationError = .noAuthSession
        let request = MockRequest(urlRequest: URLRequest(url: URL(string: "https://www.test.com")!), requiresAuthentication: true)
        var outputError: NetworkError?
        networker
            .publisher(for: request)
            .sink {
                if case .failure(let error) = $0 {
                    outputError = error
                }
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 60)
        
        if case .notAuthenticated = outputError {
            XCTAssert(true)
        } else {
            XCTFail("Expected a not authenticated error")
        }
    }
    
    func testRequestFailsWithNotAuthenticated_WhenAuthenticatorReturnsRefreshFailed() {
        let expectation = XCTestExpectation()
        
        authenticator.authenticationError = .refreshFailed
        let request = MockRequest(urlRequest: URLRequest(url: URL(string: "https://www.test.com")!), requiresAuthentication: true)
        var outputError: NetworkError?
        networker
            .publisher(for: request)
            .sink {
                if case .failure(let error) = $0 {
                    outputError = error
                }
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 60)
        
        if case .notAuthenticated = outputError {
            XCTAssert(true)
        } else {
            XCTFail("Expected a not authenticated error")
        }
    }
    
    func testRequestRetries3Times_OnRequestFailure() {
        let expectation = XCTestExpectation()
        
        MockNetworkProtocol.responseHandler = { _ in
            return (nil, URLError(.notConnectedToInternet))
        }
        
        authenticator.authenticationUpdater = { $0.urlRequest }
        let request = MockRequest(urlRequest: URLRequest(url: URL(string: "https://www.test.com")!), requiresAuthentication: true)
        networker
            .publisher(for: request)
            .sink { _ in
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 60)
        
        // Initial request, plus 3 retries
        XCTAssertEqual(4, MockNetworkProtocol.requests.count)
    }
    
    func testRequestRetries_WithForceAuthRefresh_WhenReceive401() {
        let expectation = XCTestExpectation()
        
        MockNetworkProtocol.responseHandler = { _ in
            return ((Data(), 401), nil)
        }
        
        authenticator.authenticationUpdater = { $0.urlRequest }
        let request = MockRequest(urlRequest: URLRequest(url: URL(string: "https://www.test.com")!), requiresAuthentication: true)
        networker
            .publisher(for: request)
            .sink { _ in
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 60)
        
        XCTAssertEqual(2, authenticator.authentications.count)
        XCTAssertEqual(false, authenticator.authentications.first?.calledWithForceRefresh)
        XCTAssertEqual(true, authenticator.authentications.last?.calledWithForceRefresh)
    }
    
    func testRequestReturnsUrlError_OnFailure() {
        let expectation = XCTestExpectation()
        
        MockNetworkProtocol.responseHandler = { _ in
            return (nil, URLError(.badServerResponse))
        }
        
        authenticator.authenticationUpdater = { $0.urlRequest }
        let request = MockRequest(urlRequest: URLRequest(url: URL(string: "https://www.test.com")!), requiresAuthentication: true)
        var outputError: NetworkError?
        networker
            .publisher(for: request)
            .sink {
                if case .failure(let error) = $0 {
                    outputError = error
                }
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 60)
        
        if case .urlError(let error) = outputError {
            XCTAssertEqual(URLError.Code.badServerResponse.rawValue, error.errorCode)
        } else {
            XCTFail("Expected a URLError")
        }
    }
    
    func testRequestReturnsDataAndResponse() {
        let expectation = XCTestExpectation()
        
        MockNetworkProtocol.responseHandler = { _ in
            return (("Hello, World".data(using: .utf8)!, 201), nil)
        }
        
        authenticator.authenticationUpdater = { $0.urlRequest }
        let request = MockRequest(urlRequest: URLRequest(url: URL(string: "https://www.test.com")!), requiresAuthentication: true)
        var outputData: Data?
        var outputResponse: URLResponse?
        networker
            .publisher(for: request)
            .sink { _ in
                expectation.fulfill()
            } receiveValue: {
                outputData = $0
                outputResponse = $1
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 60)
        
        XCTAssertEqual("Hello, World", outputData.flatMap { String(data: $0, encoding: .utf8) })
        XCTAssertEqual(201, (outputResponse as? HTTPURLResponse)?.statusCode)
    }
    
    func testRequestReturnsDataAndResponse_After3FailedAttempts() {
        let expectation = XCTestExpectation()
        
        var counter = 0
        
        MockNetworkProtocol.responseHandler = { _ in
            defer {
                counter += 1
            }
            if counter < 3 {
                return (nil, URLError(.notConnectedToInternet))
            } else {
                return (("Hello, World".data(using: .utf8)!, 201), nil)
            }
        }
        
        authenticator.authenticationUpdater = { $0.urlRequest }
        let request = MockRequest(urlRequest: URLRequest(url: URL(string: "https://www.test.com")!), requiresAuthentication: true)
        var outputData: Data?
        var outputResponse: URLResponse?
        networker
            .publisher(for: request)
            .sink { _ in
                expectation.fulfill()
            } receiveValue: {
                outputData = $0
                outputResponse = $1
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 60)
        
        XCTAssertEqual("Hello, World", outputData.flatMap { String(data: $0, encoding: .utf8) })
        XCTAssertEqual(201, (outputResponse as? HTTPURLResponse)?.statusCode)
    }
}

#endif
