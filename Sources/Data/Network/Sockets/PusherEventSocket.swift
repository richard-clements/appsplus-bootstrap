#if canImport(Foundation) && canImport(Combine) && canImport(PusherSwift)

import Foundation
import Combine
import PusherSwift

public class PusherWebSocket: EventSocket, PusherDelegate {

    class AuthRequestBuilder: AuthRequestBuilderProtocol {
        private var request: URLRequest

        init(request: URLRequest) {
            self.request = request
        }

        func requestFor(socketID: String, channelName: String) -> URLRequest? {
            request.httpBody = "socket_id=\(socketID)&channel_name=\(channelName)".data(using: .utf8)
            return request
        }
    }

    private class PusherBinder {

        private let pusher: Pusher

        var delegate: PusherDelegate? {
            get {
                return pusher.delegate
            }
            set {
                pusher.delegate = newValue
            }
        }

        var connection: ConnectionState {
            return pusher.connection.connectionState
        }

        init(key: String, options: PusherClientOptions) {
            self.pusher = Pusher(key: key, options: options)
        }

        func connect() {
            pusher.connect()
        }

        func subscribe(_ channelName: String) {
            _ = pusher.subscribe(channelName)
        }

        func unsubscribe(_ channelName: String) {
            pusher.unsubscribe(channelName)
        }

        func bind(eventCallback: @escaping (PusherEvent) -> Void) {
            pusher.bind(eventCallback: eventCallback)
        }

        func unbindAll() {
            pusher.unbindAll()
        }

        func disconnect() {
            pusher.disconnect()
        }
    }

    private var pusher: PusherBinder?
    private var authenticator: Authenticator
    private var urlSession: URLSession
    private var endpoint: URL
    private var port: Int
    private var versionNumber: String
    private var pusherKey: String
    private var eventsPublisher = PassthroughSubject<SocketMessage, Never>()
    private var subscribedChannels = [SocketChannel]()
    private var cancellables = Set<AnyCancellable>()

    public init(
        authenticator: Authenticator,
        endpoint: URL,
        port: Int,
        versionNumber: String,
        urlSession: URLSession,
        pusherKey: String
    ) {
        self.authenticator = authenticator
        self.urlSession = urlSession
        self.endpoint = endpoint
        self.versionNumber = versionNumber
        self.pusherKey = pusherKey
        self.port = port
    }

    deinit {
        disconnect()
    }

    func buildAuthenticationRequest() -> AnyPublisher<URLRequest, AuthenticatorError> {
        var urlComponents = URLComponents(url: endpoint, resolvingAgainstBaseURL: false)!
        urlComponents.path = "/api/broadcasting/auth"
        var request = URLRequest(url: urlComponents.url!, versionNumber: versionNumber)
        request.set(httpMethod: .post)

        return authenticator
            .authenticate(
                request: AuthenticatedRequest(urlRequest: request),
                forceRefresh: false,
                urlSession: urlSession
            )
            .eraseToAnyPublisher()
    }

    private func attemptConnection() -> AnyPublisher<PusherBinder, EventSocketError> {
        buildAuthenticationRequest()
            .mapError { _ in EventSocketError.unknown }
            .map { [unowned self] in
                 initializePusher($0)
            }
            .map {
                $0.connect()
                return $0
            }
            .eraseToAnyPublisher()
    }

    private func initializePusher(_ authenticationRequest: URLRequest) -> PusherBinder {
        let options = PusherClientOptions(
            authMethod: AuthMethod.authRequestBuilder(
                authRequestBuilder: AuthRequestBuilder(request: authenticationRequest)
            ),
            attemptToReturnJSONObject: false,
            autoReconnect: true,
            host: .host(endpoint.host!),
            port: port,
            useTLS: false,
            activityTimeout: 60
        )

        pusher = PusherBinder(key: pusherKey, options: options)
        pusher!.delegate = self
        return pusher!
    }

    public func disconnect() {
        pusher?.disconnect()
        pusher = nil
    }

    public func subscribe(to channel: SocketChannel, for events: [SocketEvent]) -> AnyPublisher<SocketMessage, Never> {
        subscribedChannels.append(channel)
        let filter: (SocketMessage) -> Bool = {
            return $0.channel == channel &&
            events.isEmpty ? true : (
                events + [.connected, .disconnected, .subscribed]
            ).contains($0.event)
        }

        guard let pusher = pusher, pusher.connection == .connected else {
            attemptConnection()
                .map {
                    $0.subscribe(channel.rawValue)
                }
                .sink { _ in } receiveValue: {_ in}
                .store(in: &cancellables)

            return eventsPublisher
                .share()
                .filter(filter)
                .eraseToAnyPublisher()
        }

        pusher.subscribe(channel.rawValue)

        return eventsPublisher
            .share()
            .filter(filter)
            .eraseToAnyPublisher()
    }

    public func unsubscribe(fromChannel channel: SocketChannel) {
        pusher?.unsubscribe(channel.rawValue)
        subscribedChannels.removeAll { $0.rawValue == channel.rawValue }
    }

    public func failedToSubscribeToChannel(name: String, response: URLResponse?, data: String?, error: NSError?) {
        print("Failed to subscribe to channel: \(name)")
    }

    public func subscribedToChannel(name: String) {
        guard let channel = subscribedChannels.first(where: { $0.rawValue == name }) else {
            return
        }

        eventsPublisher.send(.init(channel: channel, event: .subscribed, data: nil))
    }

    public func changedConnectionState(from old: ConnectionState, to new: ConnectionState) {
        switch new {
        case .disconnected:
            eventsPublisher.send(.init(channel: nil, event: .disconnected, data: nil))
        case .connected:
            eventsPublisher.send(.init(channel: nil, event: .connected, data: nil))
            pusher?.unbindAll()
            pusher?.bind(
                eventCallback: { [unowned self] (item: PusherEvent) in
                    guard let channel = subscribedChannels.first(where: { $0.rawValue == item.channelName }) else {
                        return
                    }
                    let event = SocketEvent(rawValue: item.eventName)

                    let data = item.data
                        .flatMap { $0.data(using: .utf8) }
                        .flatMap { try? JSONSerialization.jsonObject(with: $0, options: []) }
                        .flatMap { $0 as? [String: Any?] }

                    eventsPublisher.send(.init(channel: channel, event: event, data: data))
                }
            )
        default:
            break
        }
    }
}

#endif
