#if canImport(Foundation) && canImport(SwiftCheck) && canImport(Combine)

import Foundation
import SwiftCheck
import Combine
@testable import AppsPlus

extension MockAuthToken: Arbitrary {
    
    public static var arbitrary: Gen<MockAuthToken> {
        generator()
    }
    
    static func generator(accessTokenGenerator: Gen<String>? = nil, refreshTokenGenerator: Gen<String>? = nil, emailVerifiedGenerator: Gen<String>? = nil) -> Gen<MockAuthToken> {
        Gen.compose { composer in
            let accessToken = accessTokenGenerator.map { composer.generate(using: $0) } ?? composer.generate()
            let refreshToken = refreshTokenGenerator.map { composer.generate(using: $0) } ?? composer.generate()
            return MockAuthToken(accessToken: accessToken, refreshToken: refreshToken)
        }
    }
    
}

class MockAuthSessionProvider: AuthSessionProvider {
    
    var currentAuthSession: MockAuthToken?
    var replacedAuthSession: MockAuthToken?
    var didCallReplace = false
    var replaceSuccess = false
    var currentDeviceName: String?
    var authSessionPublisherPassthroughSubject = PassthroughSubject<AuthToken?, Never>()
    
    func current() -> MockAuthToken? {
        currentAuthSession
    }
    
    func replace(with token: MockAuthToken?) -> Bool {
        didCallReplace = true
        replacedAuthSession = token
        return replaceSuccess
    }
    
    var deviceName: String {
        return currentDeviceName!
    }
    
    func authSessionPublisher() -> AnyPublisher<MockAuthToken?, Never> {
        authSessionPublisherPassthroughSubject.share().eraseToAnyPublisher()
    }
    
}

#endif
