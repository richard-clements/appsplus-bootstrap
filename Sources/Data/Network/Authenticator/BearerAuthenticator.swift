#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public class BearerAuthenticator<ASProvider: AuthSessionProvider>: Authenticator {
    
    private let queue: DispatchQueue
    private var refreshPublisher: AnyPublisher<ASProvider.AuthToken, AuthenticatorError>?
    private let authSessionProvider: ASProvider
    private let refreshUrl: URL
    private let version: String
    
    public init(authSessionProvider: ASProvider, refreshUrl: URL, bundleIdentifier: String, version: String) {
        self.authSessionProvider = authSessionProvider
        self.refreshUrl = refreshUrl
        self.version = version
        self.queue = DispatchQueue(label: bundleIdentifier.appending(".network.bearerauthenticator"))
    }
    
    private func refreshToken(authSession: ASProvider.AuthToken, urlSession: URLSession) -> AnyPublisher<ASProvider.AuthToken, AuthenticatorError> {
        queue.sync {
            if let refreshPublisher = refreshPublisher {
                return refreshPublisher
            }
            
            var request = URLRequest(url: refreshUrl)
            request.set(httpMethod: .post)
            request.set(headerField: .authorization, value: .bearer(token: authSession.refreshToken))
            request.set(headerField: .accept, value: .applicationJson)
            request.set(headerField: .contentType, value: .applicationJson)
            request.set(headerField: .deviceType, value: .ios)
            request.set(headerField: .deviceVersion, value: HTTPHeaderValue(version))
            request.httpBody = try? JSONSerialization.data(withJSONObject: [
                "device_name": authSessionProvider.deviceName
            ], options: [])
            
            let refreshPublisher = urlSession
                .dataTaskPublisher(for: request)
                .retry(3)
                .map(\.data)
                .decode(type: ASProvider.AuthToken.self, decoder: JSONDecoder())
                .tryMap { [unowned self] token -> ASProvider.AuthToken in
                    guard authSessionProvider.replace(with: token) else {
                        throw AuthenticatorError.refreshFailed
                    }
                    return token
                }
                .mapError { _ in AuthenticatorError.refreshFailed }
                .handleEvents(receiveCompletion: { [weak self] in
                    if case .failure = $0 {
                        _ = self?.authSessionProvider.replace(with: nil)
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
        
        guard let authSession = authSessionProvider.current() else {
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
