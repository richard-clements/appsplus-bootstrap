#if canImport(XCTest) && canImport(SwiftCheck) && canImport(Combine)

import XCTest
import SwiftCheck
import Combine
@testable import AppsPlus

class BearerAuthenticatorTests: XCTestCase {
    
    var session: URLSession!
    var refreshUrl: URL!
    var authSessionProvider: MockAuthSessionProvider!
    var authenticator: BearerAuthenticator<MockAuthSessionProvider>!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        MockNetworkProtocol.setUpForTests()
        session = URLSession.mock
        refreshUrl = URL(string: "https://www.test.com/refreshtoken")!
        authSessionProvider = MockAuthSessionProvider()
        authSessionProvider.currentDeviceName = "my_test_device"
        authenticator = BearerAuthenticator(authSessionProvider: authSessionProvider, refreshUrl: refreshUrl, bundleIdentifier: "testingidentifier", version: "device_version")
        cancellables = Set()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        MockNetworkProtocol.tearDownForTests()
        session = nil
        refreshUrl = nil
        authSessionProvider = nil
        authenticator = nil
        cancellables = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAuthenticatingRequests() {
        property("Requests which do not require authentication remain unaltered") <- forAll(MockRequest.generator(requiresAuthenticationGenerator: .pure(false)), Bool.arbitrary) { [unowned self] request, forceRefresh in
            let expectation = XCTestExpectation()
            var outputRequest: URLRequest?
            authenticator.authenticate(request: request, forceRefresh: forceRefresh, urlSession: session)
                .sink { _ in
                    expectation.fulfill()
                } receiveValue: {
                    outputRequest = $0
                }
                .store(in: &cancellables)
            wait(for: [expectation], timeout: 2)
            return outputRequest == request.urlRequest
        }
        
        property("Requests which do require authentication are updated with valid access token") <- forAll(MockRequest.generator(requiresAuthenticationGenerator: .pure(true)), MockAuthToken.generator()) { [unowned self] request, authSession in
            let expectation = XCTestExpectation()
            authSessionProvider.currentAuthSession = authSession
            var outputRequest: URLRequest?
            authenticator.authenticate(request: request, forceRefresh: false, urlSession: session)
                .sink { _ in
                    expectation.fulfill()
                } receiveValue: {
                    outputRequest = $0
                }
                .store(in: &cancellables)
            wait(for: [expectation], timeout: 2)
            return outputRequest?.url == request.urlRequest.url && outputRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer \(authSession.accessToken)"
        }
        
        property("Requests which require authentication fail when no auth session provided") <- forAll(MockRequest.generator(requiresAuthenticationGenerator: .pure(true))) { [unowned self] request in
            let expectation = XCTestExpectation()
            authSessionProvider.currentAuthSession = nil
            var outputError: AuthenticatorError?
            authenticator.authenticate(request: request, forceRefresh: false, urlSession: session)
                .sink {
                    if case .failure(let error) = $0 {
                        outputError = error
                    }
                    expectation.fulfill()
                } receiveValue: { _ in }
                .store(in: &cancellables)
            wait(for: [expectation], timeout: 2)
            return outputError == .noAuthSession
        }
    }
    
    func testRequestAttemptToRefreshWhenForceRefreshIsTrue() {
        let request = MockRequest(urlRequest: URLRequest(url: URL(string: "https://test.com/resource?param1=1")!), requiresAuthentication: true)
        let expectation = XCTestExpectation()
        authSessionProvider.currentAuthSession = MockAuthToken(accessToken: "ACCESS_TOKEN", refreshToken: "REFRESH_TOKEN")
        authenticator.authenticate(request: request, forceRefresh: true, urlSession: session)
            .sink { _ in
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 2)
        
        let uniqueRequestsMade = Set(MockNetworkProtocol.requests)
        guard uniqueRequestsMade.count == 1 else {
            XCTFail("Expected only a single request to have been made")
            return
        }
        
        let requestData = (try? JSONSerialization.jsonObject(with: uniqueRequestsMade.first!.httpBody!, options: [])) as? [String: Any]
        
        XCTAssertEqual(refreshUrl, uniqueRequestsMade.first!.url)
        XCTAssertEqual("my_test_device", requestData?["device_name"] as? String)
        XCTAssertEqual("Bearer REFRESH_TOKEN", uniqueRequestsMade.first!.value(forHTTPHeaderField: "Authorization"))
        XCTAssertEqual("ios", uniqueRequestsMade.first?.value(forHTTPHeaderField: "Device-Type"))
        XCTAssertEqual("device_version", uniqueRequestsMade.first?.value(forHTTPHeaderField: "Device-Version"))
        XCTAssertEqual("application/json", uniqueRequestsMade.first?.value(forHTTPHeaderField: "Content-Type"))
        XCTAssertEqual("application/json", uniqueRequestsMade.first?.value(forHTTPHeaderField: "Accept"))
        XCTAssertEqual("POST", uniqueRequestsMade.first?.httpMethod)
    }
    
    func testRefreshRequestRetries3Times_OnRequestFailure() {
        let request = MockRequest(urlRequest: URLRequest(url: URL(string: "https://test.com/resource?param1=1")!), requiresAuthentication: true)
        let expectation = XCTestExpectation()
        authSessionProvider.currentAuthSession = MockAuthToken(accessToken: "ACCESS_TOKEN", refreshToken: "REFRESH_TOKEN")
        
        MockNetworkProtocol.responseHandler = { _ in
            return (nil, URLError(.notConnectedToInternet))
        }
        
        authenticator.authenticate(request: request, forceRefresh: true, urlSession: session)
            .sink { _ in
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 2)
        
        // Initial request, plus 3 retries
        XCTAssertEqual(4, MockNetworkProtocol.requests.count)
    }
    
    func testRefreshRequestDoesNotRetry_OnRequestResponse() {
        let request = MockRequest(urlRequest: URLRequest(url: URL(string: "https://test.com/resource?param1=1")!), requiresAuthentication: true)
        let expectation = XCTestExpectation()
        authSessionProvider.currentAuthSession = MockAuthToken(accessToken: "ACCESS_TOKEN", refreshToken: "REFRESH_TOKEN")
        
        MockNetworkProtocol.responseHandler = { _ in
            return ((Data(), 401), nil)
        }
        
        authenticator.authenticate(request: request, forceRefresh: true, urlSession: session)
            .sink { _ in
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(1, MockNetworkProtocol.requests.count)
    }
    
    func testRequestFailsWithRefreshFailed_OnRefreshRequestFailure() {
        let request = MockRequest(urlRequest: URLRequest(url: URL(string: "https://test.com/resource?param1=1")!), requiresAuthentication: true)
        let expectation = XCTestExpectation()
        authSessionProvider.currentAuthSession = MockAuthToken(accessToken: "ACCESS_TOKEN", refreshToken: "REFRESH_TOKEN")
        
        MockNetworkProtocol.responseHandler = { _ in
            return ((Data(), 401), nil)
        }
        
        var outputError: AuthenticatorError?
        authenticator.authenticate(request: request, forceRefresh: true, urlSession: session)
            .sink {
                if case .failure(let error) = $0 {
                    outputError = error
                }
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(.refreshFailed, outputError)
        XCTAssertNil(authSessionProvider.replacedAuthSession)
        XCTAssertTrue(authSessionProvider.didCallReplace)
    }
    
    func testRequestFailsWithRefreshFailed_OnRefreshReplacementFailure() {
        let request = MockRequest(urlRequest: URLRequest(url: URL(string: "https://test.com/resource?param1=1")!), requiresAuthentication: true)
        let expectation = XCTestExpectation()
        authSessionProvider.currentAuthSession = MockAuthToken(accessToken: "ACCESS_TOKEN", refreshToken: "REFRESH_TOKEN")
        authSessionProvider.replaceSuccess = false
        
        MockNetworkProtocol.responseHandler = { _ in
            let tokenData = """
            {
                "token": "NEW_ACCESS_TOKEN",
                "refresh_token": "NEW_REFRESH_TOKEN"
            }
            """.data(using: .utf8)!
            return ((tokenData, 200), nil)
        }
        
        var outputError: AuthenticatorError?
        authenticator.authenticate(request: request, forceRefresh: true, urlSession: session)
            .sink {
                if case .failure(let error) = $0 {
                    outputError = error
                }
                expectation.fulfill()
            } receiveValue: { _ in }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(.refreshFailed, outputError)
    }
    
    func testRequestUpdatesWithNewAuthSession_OnSuccessfulRefresh() {
        let request = MockRequest(urlRequest: URLRequest(url: URL(string: "https://test.com/resource?param1=1")!), requiresAuthentication: true)
        let expectation = XCTestExpectation()
        authSessionProvider.currentAuthSession = MockAuthToken(accessToken: "ACCESS_TOKEN", refreshToken: "REFRESH_TOKEN")
        authSessionProvider.replaceSuccess = true
        
        MockNetworkProtocol.responseHandler = { _ in
            let tokenData = """
            {
                "accessToken": "NEW_ACCESS_TOKEN",
                "refreshToken": "NEW_REFRESH_TOKEN"
            }
            """.data(using: .utf8)!
            return ((tokenData, 200), nil)
        }
        
        var outputRequest: URLRequest?
        authenticator.authenticate(request: request, forceRefresh: true, urlSession: session)
            .sink { _ in
                expectation.fulfill()
            } receiveValue: {
                outputRequest = $0
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(request.urlRequest.url, outputRequest?.url)
        XCTAssertEqual("NEW_ACCESS_TOKEN", authSessionProvider.replacedAuthSession?.accessToken)
        XCTAssertEqual("NEW_REFRESH_TOKEN", authSessionProvider.replacedAuthSession?.refreshToken)
        XCTAssertEqual("Bearer NEW_ACCESS_TOKEN", outputRequest?.value(forHTTPHeaderField: "Authorization"))
    }
    
    func testMultipleRequestsUsePendingRefreshTokenHandler() {
        let expectation = XCTestExpectation()
        authSessionProvider.currentAuthSession = MockAuthToken(accessToken: "ACCESS_TOKEN", refreshToken: "REFRESH_TOKEN")
        authSessionProvider.replaceSuccess = true
        
        MockNetworkProtocol.delay = 0.5
        MockNetworkProtocol.responseHandler = { request in
            let tokenData = """
            {
                "accessToken": "NEW_ACCESS_TOKEN",
                "refreshToken": "NEW_REFRESH_TOKEN"
            }
            """.data(using: .utf8)!
            return ((tokenData, 200), nil)
        }
        
        let requests = [
            MockRequest(urlRequest: URLRequest(url: URL(string: "https://test.com/resource?param1=1")!), requiresAuthentication: true),
            MockRequest(urlRequest: URLRequest(url: URL(string: "https://test.com/resource?param1=2")!), requiresAuthentication: true),
            MockRequest(urlRequest: URLRequest(url: URL(string: "https://test.com/resource?param1=3")!), requiresAuthentication: true),
            MockRequest(urlRequest: URLRequest(url: URL(string: "https://test.com/resource?param1=4")!), requiresAuthentication: true)
        ]
        
        var outputRequests = [URLRequest]()
        requests
            .publisher
            .setFailureType(to: AuthenticatorError.self)
            .flatMap { [unowned self] in
                authenticator.authenticate(request: $0, forceRefresh: true, urlSession: session)
            }
            .sink { _ in
                expectation.fulfill()
            } receiveValue: {
                outputRequests.append($0)
            }
            .store(in: &cancellables)
        wait(for: [expectation], timeout: 60)
        
        let expectedAccessTokens = Array(repeating: "Bearer NEW_ACCESS_TOKEN", count: 4)
        let accessTokens = outputRequests.map { $0.value(forHTTPHeaderField: "Authorization") }
        
        XCTAssertEqual(1, MockNetworkProtocol.requests.count)
        XCTAssertEqual(expectedAccessTokens, accessTokens)
    }
    
    func testTokensCanBeRefreshedConsecutively() {
        authSessionProvider.currentAuthSession = MockAuthToken(accessToken: "ACCESS_TOKEN", refreshToken: "REFRESH_TOKEN")
        authSessionProvider.replaceSuccess = true
        
        var counter = 0
        MockNetworkProtocol.delay = 0
        MockNetworkProtocol.responseHandler = { request in
            counter += 1
            let tokenData = """
            {
                "accessToken": "NEW_ACCESS_TOKEN_\(counter)",
                "refreshToken": "NEW_REFRESH_TOKEN_\(counter)"
            }
            """.data(using: .utf8)!
            return ((tokenData, 200), nil)
        }
        
        var outputRequests = [URLRequest]()
        let expectationRequest1 = XCTestExpectation()
        authenticator.authenticate(request: MockRequest(urlRequest: URLRequest(url: URL(string: "https://test.com/resource?param1=1")!), requiresAuthentication: true), forceRefresh: true, urlSession: session)
            .sink { _ in
                expectationRequest1.fulfill()
            } receiveValue: {
                outputRequests.append($0)
            }
            .store(in: &cancellables)
        wait(for: [expectationRequest1], timeout: 2)
        
        let expectationRequest2 = XCTestExpectation()
        authenticator.authenticate(request: MockRequest(urlRequest: URLRequest(url: URL(string: "https://test.com/resource?param1=1")!), requiresAuthentication: true), forceRefresh: true, urlSession: session)
            .sink { _ in
                expectationRequest2.fulfill()
            } receiveValue: {
                outputRequests.append($0)
            }
            .store(in: &cancellables)
        wait(for: [expectationRequest2], timeout: 2)
        
        let expectedAccessTokens = [
            "Bearer NEW_ACCESS_TOKEN_1",
            "Bearer NEW_ACCESS_TOKEN_2"
        ]
        let outputAccessTokens = outputRequests.map { $0.value(forHTTPHeaderField: "Authorization") }
        
        XCTAssertEqual(expectedAccessTokens, outputAccessTokens)
    }
}

#endif
