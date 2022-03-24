import AppsPlusData
import Combine

public class MockEventSocket: EventSocket {
    
    public init() {}
    
    public var disconnectCalled = false
    public func disconnect() {
        disconnectCalled = true
    }
    
    var subscribeToChannel: SocketChannel?
    var subscribeEvents: [SocketEvent]?
    var subscriptionPublisher: AnyPublisher<SocketMessage, Never> = PassthroughSubject<SocketMessage, Never>().eraseToAnyPublisher()
    public func subscribe(to channel: SocketChannel, for events: [SocketEvent]) -> AnyPublisher<SocketMessage, Never> {
        subscribeToChannel = channel
        subscribeEvents = events
        return subscriptionPublisher
    }
    
}
