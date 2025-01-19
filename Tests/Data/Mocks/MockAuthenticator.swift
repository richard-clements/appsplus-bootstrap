#if canImport(Foundation)

import Foundation
@testable import AppsPlusData

@available(iOS 15.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class MockAuthenticator: Authenticator {
    
    var authenticationUpdater: ((Request) -> URLRequest)?
    var authenticationError: AuthenticatorError?
    var authentications = [(request: Request, calledWithForceRefresh: Bool)]()
    
    func authenticate(request: any AppsPlusData.Request, forceRefresh: Bool, urlSession: URLSession) async throws -> URLRequest {
        authentications.append((request, forceRefresh))
        if let authenticationError = authenticationError {
            throw authenticationError
        } else if let authenticationUpdater = authenticationUpdater {
            return authenticationUpdater(request)
        } else {
            throw AuthenticatorError.refreshFailed
        }
    }
    
}

#endif
