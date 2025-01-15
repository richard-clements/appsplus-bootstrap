//#if canImport(Foundation) && canImport(Combine)
//
//import Foundation
//import Combine
//
//@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
//public class BearerAuthenticator<AuthToken: AuthTokenProtocol>: Authenticator {
//    
//    private let queue: DispatchQueue
//    private var refreshPublisher: AnyPublisher<AuthToken, AuthenticatorError>?
//    private let authSessionProvider: AuthSessionProvider
//    private let refreshUrl: URL?
//    private let version: String
//    
//    public init(authSessionProvider: AuthSessionProvider, refreshUrl: URL?, bundleIdentifier: String, version: String) {
//        self.authSessionProvider = authSessionProvider
//        self.refreshUrl = refreshUrl
//        self.version = version
//        self.queue = DispatchQueue(label: bundleIdentifier.appending(".network.bearerauthenticator"))
//    }
//    
//    private func refreshToken(authSession: AuthToken, urlSession: URLSession) -> AnyPublisher<AuthToken, AuthenticatorError> {
//        guard let refreshUrl = refreshUrl else {
//            return Fail(error: AuthenticatorError.refreshFailed).eraseToAnyPublisher()
//        }
//        return queue.sync {
//            if let refreshPublisher = refreshPublisher {
//                return refreshPublisher
//            }
//            
//            var request = URLRequest(url: refreshUrl, versionNumber: version)
//            request.set(httpMethod: .post)
//            request.set(headerField: .authorization, value: .bearer(token: authSession.refreshToken))
//            try? request.set(httpBody: [
//                "device_name": authSessionProvider.deviceName
//            ])
//            
//            let refreshPublisher = urlSession
//                .dataTaskPublisher(for: request)
//                .retry(3)
//                .map(\.data)
//                .decode(type: AuthToken.self, decoder: JSONDecoder())
//                .tryMap { [unowned self] token -> AuthToken in
//                    guard authSessionProvider.replace(with: token) else {
//                        throw AuthenticatorError.refreshFailed
//                    }
//                    return token
//                }
//                .mapError { _ in AuthenticatorError.refreshFailed }
//                .handleEvents(receiveCompletion: { [weak self] in
//                    if case .failure = $0 {
//                        _ = self?.authSessionProvider.remove()
//                    }
//                    self?.queue.sync {
//                        self?.refreshPublisher = nil
//                    }
//                })
//                .share()
//                .eraseToAnyPublisher()
//            self.refreshPublisher = refreshPublisher
//            return refreshPublisher
//        }
//    }
//    
//    public func authenticate(request: Request, forceRefresh: Bool, urlSession: URLSession) -> AnyPublisher<URLRequest, AuthenticatorError> {
//        guard request.requiresAuthentication else {
//            return Just(request.urlRequest)
//                .setFailureType(to: AuthenticatorError.self)
//                .eraseToAnyPublisher()
//        }
//        
//        guard let authSession = authSessionProvider.current(as: AuthToken.self) else {
//            return Fail(error: .noAuthSession)
//                .eraseToAnyPublisher()
//        }
//        
//        if forceRefresh {
//            return refreshToken(authSession: authSession, urlSession: urlSession)
//                .map {
//                    var urlRequest = request.urlRequest
//                    urlRequest.set(headerField: .authorization, value: .bearer(token: $0.accessToken))
//                    return urlRequest
//                }
//                .eraseToAnyPublisher()
//        }
//        
//        var urlRequest = request.urlRequest
//        urlRequest.set(headerField: .authorization, value: .bearer(token: authSession.accessToken))
//        return Just(urlRequest)
//            .setFailureType(to: AuthenticatorError.self)
//            .eraseToAnyPublisher()
//    }
//    
//}
//
//#endif

#if canImport(Foundation)

import Foundation

@available(iOS 15.0, tvOS 15.0, macOS 12.0, watchOS 8.0, *)
public class BearerAuthenticator<AuthToken: AuthTokenProtocol>: Authenticator {

    private let authSessionProvider: AuthSessionProvider
    private let refreshUrl: URL?
    private let version: String
    private var isRefreshing = false

    public init(authSessionProvider: AuthSessionProvider, refreshUrl: URL?, bundleIdentifier: String, version: String) {
        self.authSessionProvider = authSessionProvider
        self.refreshUrl = refreshUrl
        self.version = version
    }

    private func refreshToken(authSession: AuthToken, urlSession: URLSession) async throws -> AuthToken {
        guard let refreshUrl = refreshUrl else {
            throw AuthenticatorError.refreshFailed
        }

        // Ensure only one refresh operation at a time
        if isRefreshing {
            throw AuthenticatorError.refreshFailed // Handle concurrent refresh requests
        }

        isRefreshing = true
        defer { isRefreshing = false }

        var request = URLRequest(url: refreshUrl, versionNumber: version)
        request.set(httpMethod: .post)
        try request.set(httpBody: ["device_name": authSessionProvider.deviceName])
        request.set(headerField: .authorization, value: .bearer(token: authSession.refreshToken))

        do {
            let (data, _) = try await urlSession.data(for: request)
            let token = try JSONDecoder().decode(AuthToken.self, from: data)

            guard authSessionProvider.replace(with: token) else {
                _ = authSessionProvider.remove()
                throw AuthenticatorError.refreshFailed
            }
            return token
        } catch {
            _ = authSessionProvider.remove()
            throw AuthenticatorError.refreshFailed
        }
    }

    public func authenticate(request: Request, forceRefresh: Bool, urlSession: URLSession) async throws -> URLRequest {
        guard request.requiresAuthentication else {
            return request.urlRequest
        }

        guard let authSession = authSessionProvider.current(as: AuthToken.self) else {
            throw AuthenticatorError.noAuthSession
        }

        if forceRefresh {
            let token = try await refreshToken(authSession: authSession, urlSession: urlSession)
            var urlRequest = request.urlRequest
            urlRequest.set(headerField: .authorization, value: .bearer(token: token.accessToken))
            return urlRequest
        } else {
            var urlRequest = request.urlRequest
            urlRequest.set(headerField: .authorization, value: .bearer(token: authSession.accessToken))
            return urlRequest
        }
    }
}

#endif
