#if canImport(Foundation)

import Foundation

extension HTTPURLResponse {
    
    public var isSuccessful: Bool {
        200 ..< 300 ~= statusCode
    }
    
    public var isUnauthorized: Bool {
        statusCode == 401
    }
    
}

#endif
