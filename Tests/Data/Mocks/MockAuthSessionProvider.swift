#if canImport(Foundation) && canImport(SwiftCheck) && canImport(Combine)

import Foundation
import SwiftCheck
import Combine
@testable import AppsPlusData

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

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class MockAuthSessionProvider: AuthSessionProvider {
    
    var currentAuthSession: MockAuthToken?
    var replacedAuthSession: MockAuthToken?
    var didCallReplace = false
    var replaceSuccess = false
    var currentDeviceName: String?
    var authSessionPublisherPassthroughSubject = PassthroughSubject<MockAuthToken?, Never>()
    
    func current() -> AnyAuthToken? {
        currentAuthSession?.toAnyAuthToken()
    }
    
    func current<T>(as type: T.Type) -> T? where T : AuthTokenProtocol {
        currentAuthSession as? T
    }
    
    func replace<T>(with authToken: T?) -> Bool where T : AuthTokenProtocol {
        didCallReplace = true
        replacedAuthSession = authToken as? MockAuthToken
        return replaceSuccess
    }
    
    var deviceName: String {
        return currentDeviceName!
    }
    
    func authSessionPublisher() -> AnyPublisher<AnyAuthToken?, Never> {
        authSessionPublisherPassthroughSubject
            .share()
            .map { $0?.toAnyAuthToken() }
            .eraseToAnyPublisher()
    }
    
    func authSessionPublisher<T>(for type: T.Type) -> AnyPublisher<T?, Never> where T : AuthTokenProtocol {
        authSessionPublisherPassthroughSubject
            .share()
            .map { $0 as? T }
            .eraseToAnyPublisher()
    }
    
}

#endif
