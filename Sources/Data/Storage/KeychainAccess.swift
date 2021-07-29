//
//  File.swift
//  
//
//  Created by Richard Clements on 29/07/2021.
//

#if canImport(Foundation)
import Foundation

protocol KeychainAccess {
    func set(_ value: String, key: String, ignoringAttributeSynchronizable: Bool) throws
    func set(_ value: Data, key: String, ignoringAttributeSynchronizable: Bool) throws
    
    func get(_ key: String, ignoringAttributeSynchronizable: Bool) throws -> String?
    func getData(_ key: String, ignoringAttributeSynchronizable: Bool) throws -> Data?
    
    func remove(_ key: String, ignoringAttributeSynchronizable: Bool) throws
}

#if canImport(KeychainAccess)
import KeychainAccess
extension Keychain: KeychainAccess { }
#endif

#endif
