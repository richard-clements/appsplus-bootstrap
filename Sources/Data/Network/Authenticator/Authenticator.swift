#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

public enum AuthenticatorError: Error, CaseIterable {
    case noAuthSession
    case refreshFailed
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public protocol Authenticator {
    func authenticate(request: Request, forceRefresh: Bool, urlSession: URLSession) async throws -> URLRequest
}

#endif
