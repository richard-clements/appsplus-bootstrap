//
//  File.swift
//  
//
//  Created by Richard Clements on 29/07/2021.
//

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
