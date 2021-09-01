import AppsPlusData
import Foundation
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public class MockNetwork: Network {
    
    private var enqueuedResponses = [(Request) -> AnyPublisher<(data: Data, response: URLResponse), NetworkError>?]()
    public var requestResponse: (Data, URLResponse)?
    public var networkError: NetworkError?
    
    public func publisher(for request: Request) -> AnyPublisher<(data: Data, response: URLResponse), NetworkError> {
        if let enqueuedResponse = enqueuedResponses.compactMap({ $0(request) }).first {
            return enqueuedResponse
        } else if let requestResponse = requestResponse {
            return Just(requestResponse)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: networkError ?? NetworkError.urlError(URLError(.unknown)))
                .eraseToAnyPublisher()
        }
    }

    public func enqueueResponse(_ response: @escaping (Request) -> AnyPublisher<(data: Data, response: URLResponse), NetworkError>?) {
        enqueuedResponses.append(response)
    }
    
    public func dequeueResponses() {
        enqueuedResponses.removeAll()
    }
}
