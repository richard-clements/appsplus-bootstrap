#if canImport(SwiftCheck) && canImport(Combine)

import XCTest
import SwiftCheck
import Combine
@testable import AppsPlus

class AuthSessionProviderTests: XCTestCase {
    
    var secureStorage: MockSecureStorage!
    var authSession: AuthSessionProviderImpl!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        secureStorage = MockSecureStorage()
        authSession = AuthSessionProviderImpl(secureStorage: secureStorage)
        cancellables = Set()
    }
    
    override func tearDown() {
        secureStorage = nil
        authSession = nil
        cancellables = nil
        super.tearDown()
    }
    
    func test_currentSession() {
        property("Current returns auth token from storage") <- forAll(MockAuthToken.arbitrary) { [unowned self] in
            secureStorage.items["authToken"] = $0
            
            let authToken: MockAuthToken? = authSession.current()
            
            return authToken?.accessToken == $0.accessToken &&
                authToken?.refreshToken == $0.refreshToken
        }
    }
    
    func test_replaceSession() {
        property("Replace updates auth token in storage") <- forAll(MockAuthToken.arbitrary) { [unowned self] in
            _ = authSession.replace(with: $0)
            
            let retrievedValue = secureStorage.items.values.first as? MockAuthToken
            return secureStorage.items.keys.first == "authToken" && retrievedValue == $0
        }
    }
    
    func test_currentSessionNullWithNoToken() {
        let token: MockAuthToken? = authSession.current()
        XCTAssertNil(token)
    }
    
    func test_settingNilTokenRemovesFromStorage() {
        _ = authSession.replace(with: Optional<MockAuthToken>.none)
        
        let retrievedToken = secureStorage.items["authToken"] as? MockAuthToken
        XCTAssertNil(retrievedToken)
    }
    
    func test_deviceName() {
        property("deviceName returns device name from storage") <- forAll(String.arbitrary) { [unowned self] in
            secureStorage.items["deviceName"] = $0
            return authSession.deviceName == $0
        }
    }
    
    func test_deviceNameIsRandomWhenNotInStorage() {
        let deviceName = authSession.deviceName
        XCTAssertNotNil(deviceName)
        XCTAssertNotNil(secureStorage.items["deviceName"])
    }
    
    func test_authSessionPublisher() {
        property("Auth session emits value for each replacement") <- forAll(MockAuthToken.arbitrary) { [unowned self] in
            let expectation = XCTestExpectation()
            var authToken: MockAuthToken? = nil
            authSession.authSessionPublisher()
                .sink { (token: MockAuthToken?) in
                    authToken = token
                    expectation.fulfill()
                }
                .store(in: &cancellables)
            _ = authSession.replace(with: $0)
            return authToken == $0
        }
    }
    
}
#endif
