//
//  File.swift
//  
//
//  Created by Richard Clements on 29/07/2021.
//

#if canImport(Foundation)
import Foundation

struct AuthToken: Codable {
    let accessToken: String
    let refreshToken: String
}
#endif
