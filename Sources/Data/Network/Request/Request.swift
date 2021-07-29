#if canImport(Foundation)

import Foundation

public protocol Request {
    
    var urlRequest: URLRequest { get }
    var requiresAuthentication: Bool { get }
    
}

public struct AuthenticatedRequest: Request {
    
    public let urlRequest: URLRequest
    public let requiresAuthentication = true
    
}

public struct PublicRequest: Request {
    
    public let urlRequest: URLRequest
    public let requiresAuthentication = false
    
}

#endif
