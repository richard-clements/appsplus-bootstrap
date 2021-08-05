#if canImport(Foundation)

import Foundation

public struct KeyValueStorageImpl: KeyValueStorage {
    
    private let keyValueStore: KeyValueStore
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    public init(keyValueStore: KeyValueStore, encoder: JSONEncoder, decoder: JSONDecoder) {
        self.keyValueStore = keyValueStore
        self.encoder = encoder
        self.decoder = decoder
    }
    
    func set(_ value: String?, forKey key: String) {
        keyValueStore.set(value, forKey: key)
    }
    
    func string(forKey key: String) -> String? {
        keyValueStore.string(forKey: key)
    }
    
    func setValue<E>(_ value: E, forKey key: String) where E : Encodable {
        keyValueStore.set(try? encoder.encode(value), forKey: key)
    }
    
    func value<D>(forKey key: String) -> D? where D : Decodable {
        keyValueStore.data(forKey: key).flatMap {
            try? decoder.decode(D.self, from: $0)
        }
    }
    
}

#endif
