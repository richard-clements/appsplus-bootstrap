#if canImport(Foundation)

import Foundation

struct HTTPHeaderField {
    fileprivate let rawValue: String
}

extension HTTPHeaderField: ExpressibleByStringLiteral {
    
    init(stringLiteral value: String) {
        self.rawValue = value
    }
    
}

extension HTTPHeaderField {
    static let authorization: Self = "Authorization"
    static let contentType: Self = "Content-Type"
    static let accept: Self = "Accept"
    static let deviceType: Self = "Device-Type"
    static let deviceVersion: Self = "Device-Version"
}

struct HTTPHeaderValue {
    fileprivate let rawValue: String
}

extension HTTPHeaderValue {
    
    init(_ value: String) {
        self.rawValue = value
    }
    
}

extension HTTPHeaderValue: ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    
    init(stringLiteral value: String) {
        self.rawValue = value
    }
    
}

extension HTTPHeaderValue {
    static var applicationJson: HTTPHeaderValue = "application/json"
    static var ios: HTTPHeaderValue = "ios"
    
    static func bearer(token: String) -> HTTPHeaderValue {
        "Bearer \(token)"
    }
}

extension URLRequest {
    
    mutating func set(headerField: HTTPHeaderField, value: HTTPHeaderValue?) {
        setValue(value?.rawValue, forHTTPHeaderField: headerField.rawValue)
    }
}

#endif
