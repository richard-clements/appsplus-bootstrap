#if canImport(Foundation)

import Foundation

extension URLRequest {
    
    public mutating func set<Body: Encodable>(httpBody body: Body, encoder: JSONEncoder = JSONEncoder()) throws {
        set(headerField: .contentType, value: .applicationJson)
        httpBody = try encoder.encode(body)
    }
    
}

#endif
