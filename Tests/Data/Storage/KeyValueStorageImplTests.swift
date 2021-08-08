#if canImport(SwiftCheck)

import XCTest
import SwiftCheck
@testable import AppsPlusData

class KeyValueStorageImplTests: XCTestCase {
    
    var storage: KeyValueStorageImpl!
    var keyValueStore: MockKeyValueStore!
    var encoder: JSONEncoder!
    var decoder: JSONDecoder!
    
    override func setUp() {
        super.setUp()
        keyValueStore = MockKeyValueStore()
        encoder = JSONEncoder()
        decoder = JSONDecoder()
        
        storage = KeyValueStorageImpl(keyValueStore: keyValueStore, encoder: encoder, decoder: decoder)
    }
    
    override func tearDown() {
        keyValueStore = nil
        encoder = nil
        decoder = nil
        storage = nil
        super.tearDown()
    }
    
    func test_settingValues() {
        property("Adding string value sets the string correctly") <- forAll(String.arbitrary, String.arbitrary) { [unowned self] in
            storage.set($0, forKey: KeyValueStorageKey(value: $1))
            
            return keyValueStore.addedValues[$1] as? String == $0
        }
        
        property("Adding codable value sets the value correctly") <- forAll(MockCodable.arbitrary, String.arbitrary) { [unowned self] in
            storage.setValue($0, forKey: KeyValueStorageKey(value: $1))
            let data = keyValueStore.addedValues[$1] as? Data
            
            return data == (try! encoder.encode($0))
        }
    }
    
    func test_gettingValues() {
        property("Getting string value is the same as stored string") <- forAll(String.arbitrary, String.arbitrary) { [unowned self] in
            keyValueStore.returnValues[$1] = $0
            
            return storage.string(forKey: KeyValueStorageKey(value: $1)) == $0
        }
        
        property("Getting codable value is the same as stored codeable value") <- forAll(MockCodable.arbitrary, String.arbitrary) { [unowned self] in
            let encodedData = try? encoder.encode($0)
            keyValueStore.returnValues[$1] = encodedData
            
            return storage.value(forKey: KeyValueStorageKey(value: $1)) == $0
        }
    }
    
    func test_removingValues() {
        property("Setting nil string value removes the correct key") <- forAll { [unowned self] (key: String) in
            storage.remove(key: KeyValueStorageKey(value: key))
            return keyValueStore.removedValues.contains(key)
        }
    }
    
}

#endif
