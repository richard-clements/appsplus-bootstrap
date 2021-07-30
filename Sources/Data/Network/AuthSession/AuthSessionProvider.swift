#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public protocol AuthSessionProvider {
    var deviceName: String { get }
    func current<T: AuthTokenProtocol>() -> T?
    func replace<T: AuthTokenProtocol>(with authToken: T?) -> Bool
    func authSessionPublisher<T: AuthTokenProtocol>() -> AnyPublisher<T?, Never>
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension AuthSessionProvider {
    
    public func remove() -> Bool {
        replace(with: Optional<AnyAuthToken>.none)
    }
    
}

#endif
