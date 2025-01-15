#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public enum NetworkError: Error {
    case notAuthenticated
    case urlError(URLError)
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public protocol Network {
    func perform(request: Request) async throws -> (data: Data, response: URLResponse)
    func perform(request: Request) async throws -> (data: Data, response: HTTPURLResponse)
}

#endif
