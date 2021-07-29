//
//  File.swift
//  
//
//  Created by Richard Clements on 29/07/2021.
//

#if canImport(Foundation) && canImport(Combine)
import Foundation
import Combine

extension SecureStorageKey {
    static fileprivate let deviceName = SecureStorageKey(rawValue: "deviceName")
    static fileprivate let authToken = SecureStorageKey(rawValue: "authToken")
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
struct AuthSessionProviderImpl: AuthSessionProvider {
    
    let secureStorage: SecureStorage
    private let authSessionPassthroughSubject = PassthroughSubject<AuthToken?, Never>()
    
    func current() -> AuthToken? {
        return secureStorage.value(for: .authToken)
    }
    
    func replace(with authToken: AuthToken?) -> Bool {
        let replaced = (try? secureStorage.setValue(authToken, with: .authToken)) != nil
        authSessionPassthroughSubject.send(authToken)
        return replaced
    }
    
    var deviceName: String {
        if let name = secureStorage.string(for: .deviceName) {
            return name
        }
        
        let name = UUID().uuidString
        try? secureStorage.setString(name, with: .deviceName)
        return name
    }
    
    func authSessionPublisher() -> AnyPublisher<AuthToken?, Never> {
        authSessionPassthroughSubject.share().eraseToAnyPublisher()
    }
}
#endif
