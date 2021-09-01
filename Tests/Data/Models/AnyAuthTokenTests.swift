#if canImport(SwiftCheck)

import XCTest
import SwiftCheck
@testable import AppsPlusData

class AnyAuthTokenTests: XCTestCase {
    
    func testAnyAuthTokenProperties() {
        property("Access token is the same as auth token") <- forAll(MockAuthToken.arbitrary) {
            let authToken = AnyAuthToken(token: $0)
            return authToken.accessToken == $0.accessToken
        }
        
        property("Refresh token is the same as auth token") <- forAll(MockAuthToken.arbitrary) {
            let authToken = AnyAuthToken(token: $0)
            return authToken.refreshToken == $0.refreshToken
        }
        
        property("Test equality true for same type") <- forAll(MockAuthToken.arbitrary) {
            let any1 = AnyAuthToken(token: $0)
            let any2 = AnyAuthToken(token: $0)
            return any1 == any2
        }
        
        property("Test equality false for different type") <- forAll(MockAuthToken.arbitrary) {
            let any1 = AnyAuthToken(token: $0)
            let any2 = AnyAuthToken(token: Mock2AuthToken(accessToken: $0.accessToken, refreshToken: $0.refreshToken, addedField: $0.addedField))
            return any1 != any2
        }
        
        property("Encode AnyAuthToken is same as encoding raw token") <- forAll(MockAuthToken.arbitrary) {
            let encoding1 = try? JSONEncoder().encode(AnyAuthToken(token: $0))
            let encoding2 = try? JSONEncoder().encode($0)
            return encoding1 == encoding2
        }
        
        property("Decoding token sets access token and refresh token") <- forAll(MockAuthToken.arbitrary) {
            let data = try? JSONEncoder().encode($0)
            let token = data.flatMap { try? JSONDecoder().decode(AnyAuthToken.self, from: $0) }
            return token?.accessToken == $0.accessToken && token?.refreshToken == $0.refreshToken
        }
    }
    
}

extension AnyAuthTokenTests {
    
    struct MockAuthToken: AuthTokenProtocol, Arbitrary {
        
        static var arbitrary: Gen<AnyAuthTokenTests.MockAuthToken> {
            Gen.compose {
                MockAuthToken(accessToken: $0.generate(), refreshToken: $0.generate(), addedField: $0.generate())
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case accessToken = "token"
            case refreshToken = "refresh_token"
            case addedField = "added_field"
        }
        
        let accessToken: String
        let refreshToken: String
        let addedField: String
    }
    
    struct Mock2AuthToken: AuthTokenProtocol {
        let accessToken: String
        let refreshToken: String
        let addedField: String
    }
    
}

#endif
