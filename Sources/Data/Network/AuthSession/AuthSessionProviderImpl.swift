#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

extension SecureStorageKey {
    static fileprivate let deviceName: SecureStorageKey = "deviceName"
    static fileprivate let authToken: SecureStorageKey = "authToken"
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public struct AuthSessionProviderImpl<AuthToken: AuthTokenProtocol>: AuthSessionProvider {
    
    private let secureStorage: SecureStorage
    private let authSessionPassthroughSubject = PassthroughSubject<AuthToken?, Never>()
    
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
    
    public func current() -> AuthToken? {
        return secureStorage.value(for: .authToken)
    }
    
    public func replace(with authToken: AuthToken?) -> Bool {
        let replaced = (try? secureStorage.setValue(authToken, with: .authToken)) != nil
        authSessionPassthroughSubject.send(authToken)
        return replaced
    }
    
    public func authSessionPublisher() -> AnyPublisher<AuthToken?, Never> {
        authSessionPassthroughSubject.share().eraseToAnyPublisher()
    }
}

#endif
