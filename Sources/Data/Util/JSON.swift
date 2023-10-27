#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

public enum JSONSubscriptKey: Comparable {
    
    public static func < (lhs: JSONSubscriptKey, rhs: JSONSubscriptKey) -> Bool {
        switch lhs {
        case .index(let lhsIndex):
            switch rhs {
            case .index(let rhsIndex):
                return lhsIndex < rhsIndex
            default:
                return true
            }
        case .string(let lhsString):
            switch rhs {
            case .string(let rhsString):
                return lhsString < rhsString
            default:
                return false
            }
        }
    }
    
    public static func == (lhs: JSONSubscriptKey, rhs: JSONSubscriptKey) -> Bool {
        switch lhs {
        case .index(let lhsIndex):
            switch rhs {
            case .index(let rhsIndex):
                return lhsIndex == rhsIndex
            default:
                return false
            }
        case .string(let lhsString):
            switch rhs {
            case .string(let rhsString):
                return lhsString == rhsString
            default:
                return false
            }
        }
    }
    
    case string(String)
    case index(Int)
}

public struct JSON {
    private let data: Any?
    
    public init(data: Any?) {
        self.data = data
    }
    
    public func asValue<T: Any>() -> T? {
        return data as? T
    }
    
    public var string: String? {
        return asValue()
    }
    
    public var number: NSNumber? {
        return asValue()
    }
    
    public var double: Double? {
        return number?.doubleValue
    }
    
    public var integer: Int? {
        return number?.intValue
    }
    
    public var int32: Int32? {
        return number?.int32Value
    }
    
    public var int64: Int64? {
        return number?.int64Value
    }
    
    public var bool: Bool? {
        return number?.boolValue
    }
    
    public var unsignedInteger: UInt? {
        return number?.uintValue
    }
    
    public var array: [JSON]? {
        guard let array: [Any] = asValue() else {
            return nil
        }
        return array.map { JSON(data: $0) }
    }
    
    public func asArray<T>() -> [T]? {
        return array?.compactMap { $0.asValue() }
    }
    
    public func toData() throws -> Data {
        if let data = data as? [JSON] {
            return try JSONSerialization.data(withJSONObject: data.compactMap(\.data), options: [])
        }
        return try JSONSerialization.data(withJSONObject: data as Any, options: [])
    }
    
    public subscript(_ key: JSONSubscriptKey) -> JSON? {
        if let data = data as? [String: Any],
           case let JSONSubscriptKey.string(stringKey) = key,
           !(data[stringKey] is NSNull),
           data[stringKey] != nil {
            return JSON(data: data[stringKey])
        } else if let data = data as? [Any], case let JSONSubscriptKey.index(indexKey) = key {
            return JSON(data: data[indexKey])
        } else {
            return nil
        }
    }
    
    public subscript(_ key: String) -> JSON? {
      self[.string(key)]
    }

    public subscript(_ index: Int) -> JSON? {
      self[.index(index)]
    }
    
    public func keys() -> [String] {
        if let data  = data as? [String: Any] {
            return Array(data.keys)
        } else {
            return []
        }
    }
    
    public func publisher() -> AnyPublisher<JSON, Never> {
        Just(self).eraseToAnyPublisher()
    }
}

#endif
