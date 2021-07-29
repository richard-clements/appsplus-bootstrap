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
protocol AuthSessionProvider {
    var deviceName: String { get }
    func current() -> AuthToken?
    func replace(with authToken: AuthToken?) -> Bool
    
    func authSessionPublisher() -> AnyPublisher<AuthToken?, Never>
}

#endif
