#if canImport(Foundation)

import Foundation

extension URLRequest {
    
    public init(url: URL, versionNumber: String, accept: HTTPHeaderValue? = .applicationJson) {
        self.init(url: url)
        #if os(iOS)
        set(headerField: .deviceType, value: .iOS)
        #elseif os(macOS)
        set(headerField: .deviceType, value: .macOS)
        #elseif os(tvOS)
        set(headerField: .deviceType, value: .tvOS)
        #elseif os(watchOS)
        set(headerField: .deviceType, value: .watchOS)
        #endif
        set(headerField: .deviceVersion, value: .init(versionNumber))
        set(headerField: .accept, value: accept)
    }
    
}

#endif
