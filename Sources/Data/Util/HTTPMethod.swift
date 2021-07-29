#if canImport(Foundation)

import Foundation

struct HTTPMethod {
    fileprivate let rawValue: String
}

extension HTTPMethod: ExpressibleByStringLiteral {
    
    init(stringLiteral value: String) {
        self.rawValue = value
    }
    
}

extension HTTPMethod {
    static let get: Self = "GET"
    static let patch: Self = "PATCH"
    static let post: Self = "POST"
    static let put: Self = "PUT"
    static let delete: Self = "DELETE"
}

extension URLRequest {
    
    mutating func set(httpMethod: HTTPMethod) {
        self.httpMethod = httpMethod.rawValue
    }
    
}

#endif
