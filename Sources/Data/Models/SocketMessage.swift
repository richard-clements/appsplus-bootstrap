import Foundation

public struct SocketMessage {
    public let channel: SocketChannel?
    public let event: SocketEvent
    public let data: [String: Any?]?
}
