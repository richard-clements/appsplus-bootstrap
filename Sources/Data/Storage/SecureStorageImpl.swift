#if canImport(Foundation)

import Foundation

struct SecureStorageImpl: SecureStorage {
    
    private let keychain: KeychainAccess
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    init(keychain: KeychainAccess, encoder: JSONEncoder, decoder: JSONDecoder) {
        self.keychain = keychain
        self.encoder = encoder
        self.decoder = decoder
    }
    
    func setString(_ item: String?, with key: SecureStorageKey) throws {
        if let item = item {
            try keychain.set(item, key: key.rawValue, ignoringAttributeSynchronizable: true)
        } else {
            removeItem(with: key)
        }
    }
    
    func setValue<Item: Codable>(_ item: Item?, with key: SecureStorageKey) throws {
        if let item = item {
            let encodedValue = try encoder.encode(item)
            try keychain.set(encodedValue, key: key.rawValue, ignoringAttributeSynchronizable: true)
        } else {
            removeItem(with: key)
        }
    }
    
    func string(for key: SecureStorageKey) -> String? {
        return try? keychain.get(key.rawValue, ignoringAttributeSynchronizable: true)
    }
    
    func value<Item: Codable>(for key: SecureStorageKey) -> Item? {
        guard let data = try? keychain.getData(key.rawValue, ignoringAttributeSynchronizable: true) else {
            return nil
        }
        
        return try? decoder.decode(Item.self, from: data)
    }
    
    private func removeItem(with key: SecureStorageKey) {
        try? keychain.remove(key.rawValue, ignoringAttributeSynchronizable: true)
    }
    
}
#endif
