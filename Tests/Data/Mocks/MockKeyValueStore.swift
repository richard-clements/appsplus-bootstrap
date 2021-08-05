#if canImport(Foundation)

import Foundation
@testable import AppsPlusData

class MockKeyValueStore: KeyValueStore {
    
    var addedValues = [String: Any]()
    var removedValues = [String]()
    var returnValues = [String: Any]()
    
    func set(_ value: Any?, forKey defaultName: String) {
        addedValues[defaultName] = value
    }
    
    func data(forKey defaultName: String) -> Data? {
        returnValues[defaultName] as? Data
    }
    
    func string(forKey defaultName: String) -> String? {
        returnValues[defaultName] as? String
    }
    
    func removeObject(forKey key: String) {
        removedValues.append(key)
    }
    
}


#endif
