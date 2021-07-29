#if canImport(Foundation)

import Foundation

extension HTTPURLResponse {
    
    var isSuccessful: Bool {
        200 ..< 300 ~= statusCode
    }
    
    var isUnauthorized: Bool {
        statusCode == 401
    }
    
}

#endif
