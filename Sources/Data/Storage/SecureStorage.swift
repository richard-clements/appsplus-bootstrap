#if canImport(Foundation)

import Foundation

struct SecureStorageKey {
    let rawValue: String
}

protocol SecureStorage {
    func setString(_ item: String?, with key: SecureStorageKey) throws
    func setValue<Item: Codable>(_ item: Item?, with key: SecureStorageKey) throws
    
    func string(for key: SecureStorageKey) -> String?
    func value<Item: Codable>(for key: SecureStorageKey) -> Item?
}
#endif
