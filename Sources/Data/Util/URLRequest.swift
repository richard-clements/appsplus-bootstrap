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

extension URL {
    public func appendingQueryComponent(_ item: URLQueryItem) -> URL {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        var queryItems = components?.queryItems ?? []
        queryItems.append(item)
        components?.queryItems = queryItems
        return components!.url!
    }
    
    public func appendingPageQuery(_ page: Int) -> URL {
        appendingQueryComponent(URLQueryItem(name: "page", value: page.description))
    }
}

#endif
