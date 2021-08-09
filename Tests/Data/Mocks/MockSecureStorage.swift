#if canImport(Foundation)

import Foundation
@testable import AppsPlusData

class MockSecureStorage: SecureStorage {
    
    var items = [String: Any]()
    
    func setString(_ item: String?, forKey key: SecureStorageKey) throws {
        items[key.rawValue] = item
    }
    
    func setValue<Item>(_ item: Item?, forKey key: SecureStorageKey) throws where Item : Decodable, Item : Encodable {
        items[key.rawValue] = item
    }
    
    func string(forKey key: SecureStorageKey) -> String? {
        items[key.rawValue] as? String
    }
    
    func value<Item>(forKey key: SecureStorageKey) -> Item? where Item : Decodable, Item : Encodable {
        items[key.rawValue] as? Item
    }
    
}

#endif
