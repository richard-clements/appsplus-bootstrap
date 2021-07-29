#if canImport(Foundation)

import Foundation

protocol Request {
    
    var urlRequest: URLRequest { get }
    var requiresAuthentication: Bool { get }
    
}

struct AuthenticatedRequest: Request {
    
    let urlRequest: URLRequest
    let requiresAuthentication = true
    
}

struct PublicRequest: Request {
    
    let urlRequest: URLRequest
    let requiresAuthentication = false
    
}

#endif
