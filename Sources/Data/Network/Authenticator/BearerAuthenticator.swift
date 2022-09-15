#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public class BearerAuthenticator<AuthToken: AuthTokenProtocol>: Authenticator {
    
    private let queue: DispatchQueue
    private var refreshPublisher: AnyPublisher<AuthToken, AuthenticatorError>?
    private let authSessionProvider: AuthSessionProvider
    private let refreshUrl: URL?
    private let version: String
    
    public init(authSessionProvider: AuthSessionProvider, refreshUrl: URL?, bundleIdentifier: String, version: String) {
        self.authSessionProvider = authSessionProvider
        self.refreshUrl = refreshUrl
        self.version = version
        self.queue = DispatchQueue(label: bundleIdentifier.appending(".network.bearerauthenticator"))
    }
    
    private func refreshToken(authSession: AuthToken, urlSession: URLSession) -> AnyPublisher<AuthToken, AuthenticatorError> {
        guard let refreshUrl = refreshUrl else {
            return Fail(error: AuthenticatorError.refreshFailed).eraseToAnyPublisher()
        }
        return queue.sync {
            if let refreshPublisher = refreshPublisher {
                return refreshPublisher
            }
            
            var request = URLRequest(url: refreshUrl, versionNumber: version)
            request.set(httpMethod: .post)
            request.set(headerField: .authorization, value: .bearer(token: authSession.refreshToken))
            try? request.set(httpBody: [
                "device_name": authSessionProvider.deviceName
            ])
            
            let refreshPublisher = urlSession
                .dataTaskPublisher(for: request)
                .retry(3)
                .map(\.data)
                .decode(type: AuthToken.self, decoder: JSONDecoder())
                .tryMap { [unowned self] token -> AuthToken in
                    guard authSessionProvider.replace(with: token) else {
                        throw AuthenticatorError.refreshFailed
                    }
                    return token
                }
                .mapError { _ in AuthenticatorError.refreshFailed }
                .handleEvents(receiveCompletion: { [weak self] in
                    if case .failure = $0 {
                        _ = self?.authSessionProvider.remove()
                    }
                    self?.queue.sync {
                        self?.refreshPublisher = nil
                    }
                })
                .share()
                .eraseToAnyPublisher()
            self.refreshPublisher = refreshPublisher
            return refreshPublisher
        }
    }
    
    public func authenticate(request: Request, forceRefresh: Bool, urlSession: URLSession) -> AnyPublisher<URLRequest, AuthenticatorError> {
        guard request.requiresAuthentication else {
            return Just(request.urlRequest)
                .setFailureType(to: AuthenticatorError.self)
                .eraseToAnyPublisher()
        }
        
        guard let authSession = authSessionProvider.current(as: AuthToken.self) else {
            return Fail(error: .noAuthSession)
                .eraseToAnyPublisher()
        }
        
        if forceRefresh {
            return refreshToken(authSession: authSession, urlSession: urlSession)
                .map {
                    var urlRequest = request.urlRequest
                    urlRequest.set(headerField: .authorization, value: .bearer(token: $0.accessToken))
                    return urlRequest
                }
                .eraseToAnyPublisher()
        }
        
        var urlRequest = request.urlRequest
        urlRequest.set(headerField: .authorization, value: .bearer(token: authSession.accessToken))
        return Just(urlRequest)
            .setFailureType(to: AuthenticatorError.self)
            .eraseToAnyPublisher()
    }
    
}

#endif
