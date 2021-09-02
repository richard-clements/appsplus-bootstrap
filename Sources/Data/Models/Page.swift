#if canImport(Foundation)

import Foundation

public struct Page<T> {
    
    public struct Meta: Equatable, Codable {
        public let currentPage: Int
        public let to: Int?
    }
    
    public let data: [T]
    public let meta: Meta
    
    public init(data: [T], meta: Meta) {
        self.data = data
        self.meta = meta
    }
}

extension Page: Codable where T: Codable {}
extension Page: Equatable where T: Equatable {}

extension Page {
    
    public func map<S>(_ transform: (T) throws -> S) rethrows -> Page<S> {
        let transformedData = try data.map(transform)
        return Page<S>(data: transformedData, meta: .init(currentPage: meta.currentPage, to: meta.to))
    }
    
}

#endif
