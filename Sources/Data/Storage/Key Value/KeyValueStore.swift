#if canImport(Foundation)

import Foundation

public protocol KeyValueStore {
    func set(_ value: Any?, forKey defaultName: String)
    func string(forKey defaultName: String) -> String?
    
    func bool(forKey defaultName: String) -> Bool
    func set(_ value: Bool, forKey defaultName: String)
    
    func integer(forKey defaultName: String) -> Int
    func set(_ value: Int, forKey defaultName: String)
    
    func double(forKey defaultName: String) -> Double
    func set(_ value: Double, forKey defaultName: String)
    
    func float(forKey defaultName: String) -> Float
    func set(_ value: Float, forKey defaultName: String)
    
    func data(forKey defaultName: String) -> Data?
    
}

extension UserDefaults: KeyValueStore {}

#endif
