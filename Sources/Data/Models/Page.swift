#if canImport(Foundation)

import Foundation

public struct Page<T> {
    
    public struct Meta: Equatable, Codable {
        public let currentPage: Int
        public let lastPage: Int
        
        public init(currentPage: Int, lastPage: Int) {
            self.currentPage = currentPage
            self.lastPage = lastPage
        }
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
        return Page<S>(data: transformedData, meta: .init(currentPage: meta.currentPage, lastPage: meta.lastPage))
    }
    
    public func compactMap<S>(_ transform: (T) throws -> S?) rethrows -> Page<S> {
        let transformedData = try data.compactMap(transform)
        return Page<S>(data: transformedData, meta: .init(currentPage: meta.currentPage, lastPage: meta.lastPage))
    }
    
    public func flatMap<N, S>(_ transform: ([N]) throws -> [S]) rethrows -> Page<S> where T == [N] {
        let transformedData = try data.flatMap(transform)
        return Page<S>(data: transformedData, meta: .init(currentPage: meta.currentPage, lastPage: meta.lastPage))
    }
}

extension Page {
    
    var isLastPage: Bool {
        meta.currentPage >= meta.lastPage
    }
    
    var hasNextPage: Bool {
        meta.currentPage < meta.lastPage
    }
    
}

#endif
