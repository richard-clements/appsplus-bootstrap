//
//  File.swift
//  
//
//  Created by Richard Clements on 30/07/2021.
//

import Foundation

extension URLRequest {
    
    public mutating func set<Body: Codable>(httpBody body: Body, encoder: JSONEncoder()) {
        set(headerField: .contentType, value: .applicationJson)
        httpBody = encoder.encode(body)
    }
    
}
