#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

public protocol EventSocket {
    func disconnect()
    func subscribe(to channel: SocketChannel, for events: [SocketEvent]) -> AnyPublisher<SocketMessage, Never>
    func unsubscribe(fromChannel channel: SocketChannel)
}

#endif
