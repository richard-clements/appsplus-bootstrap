#if canImport(Foundation)

import Foundation

public protocol Request {
    
    var urlRequest: URLRequest { get }
    var requiresAuthentication: Bool { get }
    
}

public struct AuthenticatedRequest: Request {
    
    public let urlRequest: URLRequest
    public let requiresAuthentication = true
    
    public init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
    
}

public struct PublicRequest: Request {
    
    public let urlRequest: URLRequest
    public let requiresAuthentication = false
    
    public init(urlRequest: URLRequest) {
        self.urlRequest = urlRequest
    }
    
}

#endif
