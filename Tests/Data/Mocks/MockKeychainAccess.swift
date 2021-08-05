import XCTest
@testable import AppsPlusData

class MockKeychainAccess: KeychainAccess {
    
    var addedValues = [SecureStorageKey: String]()
    var addedItem: Data?
    var returnedString: String?
    var returnedData: Data?
    var removedItemKey: String?
    
    func set(_ value: String, key: String, ignoringAttributeSynchronizable: Bool) throws {
        addedValues[SecureStorageKey(value: key)] = value
    }
    
    func set(_ value: Data, key: String, ignoringAttributeSynchronizable: Bool) throws {
        addedItem = value
    }
    
    func get(_ key: String, ignoringAttributeSynchronizable: Bool) throws -> String? {
        return returnedString
    }
    
    func getData(_ key: String, ignoringAttributeSynchronizable: Bool) throws -> Data? {
        return returnedData
    }
    
    func remove(_ key: String, ignoringAttributeSynchronizable: Bool) throws {
        removedItemKey = key
    }
    
}
