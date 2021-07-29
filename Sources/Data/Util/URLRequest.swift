#if canImport(Foundation)

import Foundation

extension URLRequest {
    
    public init(url: URL, versionNumber: String) {
        self.init(url: url)
        set(headerField: .accept, value: .applicationJson)
        set(headerField: .deviceType, value: .ios)
        set(headerField: .deviceVersion, value: .init(versionNumber))
    }
    
}

#endif
