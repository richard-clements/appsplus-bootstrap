#if canImport(Foundation) && canImport(Combine)
import Foundation
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension AnyPublisher where Output == (data: Data, response: URLResponse), Failure == NetworkError {
    
    func convertToHttpResponse() -> AnyPublisher<(data: Data, response: HTTPURLResponse), Error> {
        tryMap {
            guard let response = $0.response as? HTTPURLResponse else {
                throw NetworkError.urlError(URLError(.badServerResponse))
            }
            return ($0.data, response)
        }
        .eraseToAnyPublisher()
    }
}


@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension AnyPublisher where Output == (data: Data, response: HTTPURLResponse), Failure == Error {
    
    func convertToVoidResponse() -> AnyPublisher<Void, Error> {
        tryMap { (data, response) -> Void in
            if response.isSuccessful {
                return ()
            } else {
                throw data.parseServerError()
            }
        }
        .eraseToAnyPublisher()
    }
}

#endif
