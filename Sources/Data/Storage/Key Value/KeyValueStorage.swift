#if canImport(Foundation)

import Foundation

protocol KeyValueStorage {
    func setValue<E: Encodable>(_ value: E, forKey key: String)
    func value<D: Decodable>(forKey key: String) -> D?
    
    func set(_ value: String?, forKey key: String)
    func string(forKey key: String) -> String?
}

#endif
