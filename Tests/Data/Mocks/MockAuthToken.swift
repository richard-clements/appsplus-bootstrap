@testable import AppsPlus

struct MockAuthToken: AuthTokenProtocol, Codable, Equatable {
    let accessToken: String
    let refreshToken: String
}
