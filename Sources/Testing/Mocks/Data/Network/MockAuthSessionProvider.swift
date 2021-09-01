import AppsPlusData
import Foundation
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
class MockAuthSessionProvider<AuthToken: AuthTokenProtocol>: AuthSessionProvider {
    
    var currentAuthSession: AuthToken?
    var replacedAuthSession: AuthToken?
    var didCallReplace = false
    var replaceSuccess = false
    var currentDeviceName: String?
    var authSessionPublisherPassthroughSubject = PassthroughSubject<AuthToken?, Never>()
    
    func current() -> AnyAuthToken? {
        currentAuthSession?.toAnyAuthToken()
    }
    
    func current<T>(as type: T.Type) -> T? where T : AuthTokenProtocol {
        return currentAuthSession as? T
    }
    
    func replace<T>(with authToken: T?) -> Bool where T : AuthTokenProtocol {
        didCallReplace = true
        replacedAuthSession = authToken as? AuthToken
        return replaceSuccess
    }
    
    var deviceName: String {
        return currentDeviceName!
    }
    
    func authSessionPublisher<T>(for type: T.Type) -> AnyPublisher<T?, Never> where T : AuthTokenProtocol {
        authSessionPublisherPassthroughSubject
            .share()
            .map { $0 as? T }
            .eraseToAnyPublisher()
    }
    
    func authSessionPublisher() -> AnyPublisher<AnyAuthToken?, Never> {
        authSessionPublisherPassthroughSubject
            .share()
            .map { $0?.toAnyAuthToken() }
            .eraseToAnyPublisher()
    }
    
}
