//
//  File.swift
//  
//
//  Created by Richard Clements on 29/07/2021.
//

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
