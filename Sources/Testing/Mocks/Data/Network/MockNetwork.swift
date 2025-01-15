//import AppsPlusData
//import Foundation
//import Combine
//
//@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
//public class MockNetwork: Network {
//    
//    
//    
//    private var enqueuedResponses = [(Request) -> (data: Data, response: URLResponse,)]()
//    public var requestResponse: (Data, URLResponse)?
//    public var networkError: NetworkError?
//    
//    public init() {
//        
//    }
//    
//    public func perform(request: any AppsPlusData.Request) async throws -> (data: Data, response: URLResponse) {
//        <#code#>
//    }
//    
//    public func perform(request: any AppsPlusData.Request) async throws -> (data: Data, response: HTTPURLResponse) {
//        <#code#>
//    }
//    
//    public func publisher(for request: Request) -> AnyPublisher<(data: Data, response: URLResponse), NetworkError> {
//        if let enqueuedResponse = enqueuedResponses.compactMap({ $0(request) }).first {
//            return enqueuedResponse
//        } else if let requestResponse = requestResponse {
//            return Just(requestResponse)
//                .setFailureType(to: NetworkError.self)
//                .eraseToAnyPublisher()
//        } else {
//            return Fail(error: networkError ?? NetworkError.urlError(URLError(.unknown)))
//                .eraseToAnyPublisher()
//        }
//    }
//
//    public func enqueueResponse(_ response: @escaping (Request) -> AnyPublisher<(data: Data, response: URLResponse), NetworkError>?) {
//        enqueuedResponses.append(response)
//    }
//    
//    public func dequeueResponses() {
//        enqueuedResponses.removeAll()
//    }
//}
