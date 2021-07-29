//
//  File.swift
//  
//
//  Created by Richard Clements on 29/07/2021.
//

#if canImport(Foundation) && canImport(Combine)
import Foundation
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class BearerAuthenticator: Authenticator {
    
    private let queue: DispatchQueue
    private var refreshPublisher: AnyPublisher<AuthToken, AuthenticatorError>?
    private let authSessionProvider: AuthSessionProvider
    private let refreshUrl: URL
    private let version: String
    
    init(authSessionProvider: AuthSessionProvider, refreshUrl: URL, bundleIdentifier: String, version: String) {
        self.authSessionProvider = authSessionProvider
        self.refreshUrl = refreshUrl
        self.version = version
        self.queue = DispatchQueue(label: bundleIdentifier.appending(".network.bearerauthenticator"))
    }
    
    private func refreshToken(authSession: AuthToken, urlSession: URLSession) -> AnyPublisher<AuthToken, AuthenticatorError> {
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
    
    func authenticate(request: Request, forceRefresh: Bool, urlSession: URLSession) -> AnyPublisher<URLRequest, AuthenticatorError> {
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
