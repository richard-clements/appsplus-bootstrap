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
enum NetworkError: Error {
    case notAuthenticated
    case urlError(URLError)
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
protocol Network {
    func publisher(for request: Request) -> AnyPublisher<(data: Data, response: URLResponse), NetworkError>
}
#endif
