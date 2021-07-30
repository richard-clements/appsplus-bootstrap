//
//  File.swift
//  
//
//  Created by Richard Clements on 30/07/2021.
//

import Foundation

extension URLRequest {
    
    public mutating func set<Body: Codable>(httpBody body: Body, encoder: JSONEncoder = JSONEncoder()) throws {
        set(headerField: .contentType, value: .applicationJson)
        httpBody = try encoder.encode(body)
    }
    
}
