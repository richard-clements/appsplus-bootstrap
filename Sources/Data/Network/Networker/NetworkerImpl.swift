#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
struct NetworkerImpl: Network {
    
    private enum RequestError: Error {
        case unauthorized
        case authenticator(AuthenticatorError)
        case urlError(URLError)
        case unknown
    }
    
    private let session: URLSession
    private let authenticator: Authenticator
    
    init(session: URLSession, authenticator: Authenticator) {
        self.session = session
        self.authenticator = authenticator
    }
    
    func publisher(for request: Request) -> AnyPublisher<(data: Data, response: URLResponse), NetworkError> {
        publisher(for: request, forceAuthRefresh: false)
            .mapError {
                switch $0 {
                case .unknown:
                    return .urlError(URLError(.unknown))
                case .authenticator, .unauthorized:
                    return .notAuthenticated
                case .urlError(let error):
                    return .urlError(error)
                }
            }
            .eraseToAnyPublisher()
    }
    
    private func publisher(for request: Request, forceAuthRefresh: Bool) -> AnyPublisher<(data: Data, response: URLResponse), RequestError> {
        authenticator
            .authenticate(request: request, forceRefresh: forceAuthRefresh, urlSession: session)
            .mapError { RequestError.authenticator($0) }
            .flatMap {
                session.dataTaskPublisher(for: $0)
                    .retry(3)
                    .mapError { RequestError.urlError($0) }
            }
            .tryMap { (data, response) throws -> (Data, URLResponse) in
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.isUnauthorized {
                    throw RequestError.unauthorized
                }
                return (data, response)
            }
            .mapError { $0 as? RequestError ?? .unknown }
            .tryCatch { error -> AnyPublisher<(data: Data, response: URLResponse), RequestError> in
                if case .unauthorized = error, !forceAuthRefresh {
                    return publisher(for: request, forceAuthRefresh: true)
                } else {
                    throw error
                }
            }
            .mapError { $0 as? RequestError ?? .unknown }
            .eraseToAnyPublisher()
    }
    
}
#endif
