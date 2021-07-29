#if canImport(Foundation)

import Foundation

protocol AuthTokenProtocol: Codable, Equatable {
    var accessToken: String { get }
    var refreshToken: String { get }
}

#endif
