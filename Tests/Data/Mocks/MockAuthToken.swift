@testable import AppsPlusData

struct MockAuthToken: AuthTokenProtocol, Codable, Equatable {
    let accessToken: String
    let refreshToken: String
}
