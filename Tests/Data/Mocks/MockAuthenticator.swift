#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine
@testable import AppsPlus

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class MockAuthenticator: Authenticator {
    
    var authenticationUpdater: ((Request) -> URLRequest)?
    var authenticationError: AuthenticatorError?
    var authentications = [(request: Request, calledWithForceRefresh: Bool)]()
    
    func authenticate(request: Request, forceRefresh: Bool, urlSession: URLSession) -> AnyPublisher<URLRequest, AuthenticatorError> {
        authentications.append((request, forceRefresh))
        if let authenticationError = authenticationError {
            return Fail(error: authenticationError)
                .eraseToAnyPublisher()
        } else if let authenticationUpdater = authenticationUpdater {
            return Just(authenticationUpdater(request))
                .setFailureType(to: AuthenticatorError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: AuthenticatorError.refreshFailed)
                .eraseToAnyPublisher()
        }
    }
    
}

#endif
