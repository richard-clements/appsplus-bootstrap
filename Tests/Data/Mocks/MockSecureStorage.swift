#if canImport(Foundation)

import Foundation
@testable import AppsPlusData

class MockSecureStorage: SecureStorage {
    
    var items = [String: Any]()
    
    func setString(_ item: String?, with key: SecureStorageKey) throws {
        items[key.rawValue] = item
    }
    
    func setValue<Item>(_ item: Item?, with key: SecureStorageKey) throws where Item : Decodable, Item : Encodable {
        items[key.rawValue] = item
    }
    
    func string(for key: SecureStorageKey) -> String? {
        items[key.rawValue] as? String
    }
    
    func value<Item>(for key: SecureStorageKey) -> Item? where Item : Decodable, Item : Encodable {
        items[key.rawValue] as? Item
    }
    
}

#endif
