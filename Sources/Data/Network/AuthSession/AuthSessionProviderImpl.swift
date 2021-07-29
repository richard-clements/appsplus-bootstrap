#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

extension SecureStorageKey {
    static fileprivate let deviceName: SecureStorageKey = "deviceName"
    static fileprivate let authToken: SecureStorageKey = "authToken"
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public struct AuthSessionProviderImpl: AuthSessionProvider {
    
    private let secureStorage: SecureStorage
    private let authSessionPassthroughSubject = PassthroughSubject<AnyAuthToken?, Never>()
    
    public var deviceName: String {
        if let name = secureStorage.string(for: .deviceName) {
            return name
        }
        
        let name = UUID().uuidString
        try? secureStorage.setString(name, with: .deviceName)
        return name
    }
    
    public init(secureStorage: SecureStorage) {
        self.secureStorage = secureStorage
    }
    
    public func current<T: AuthTokenProtocol>() -> T? {
        return secureStorage.value(for: .authToken)
    }
    
    public func replace<T: AuthTokenProtocol>(with authToken: T?) -> Bool {
        let replaced = (try? secureStorage.setValue(authToken, with: .authToken)) != nil
        authSessionPassthroughSubject.send(authToken?.toAnyAuthToken())
        return replaced
    }
    
    public func authSessionPublisher<T: AuthTokenProtocol>() -> AnyPublisher<T?, Never> {
        authSessionPassthroughSubject
            .share()
            .map { $0?.value as? T }
            .eraseToAnyPublisher()
    }
}

#endif
