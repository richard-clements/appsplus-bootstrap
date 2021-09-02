#if canImport(Foundation)

import Foundation

public struct Page<T> {
    
    public struct Meta: Codable {
        public let currentPage: Int
        public let to: Int?
    }
    
    public let data: [T]
    public let meta: Meta
}

extension Page: Codable where T: Codable {}

extension Page {
    
    public func map<S>(_ transform: (T) throws -> S) rethrows -> Page<S> {
        let transformedData = try data.map(transform)
        return Page<S>(data: transformedData, meta: .init(currentPage: meta.currentPage, to: meta.to))
    }
    
}

#endif
