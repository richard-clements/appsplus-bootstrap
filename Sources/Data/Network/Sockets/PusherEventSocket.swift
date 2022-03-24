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
        private var subscribedChannels = [PusherChannel]()

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
            let subscribedChannel = subscribedChannels.first {
                $0.name == channelName &&
                $0.subscribed
            }
            guard subscribedChannel == nil else {
                return
            }
            subscribedChannels.append(pusher.subscribe(channelName))
        }

        func unsubscribe(_ channelName: String) {
            pusher.unsubscribe(channelName)
            subscribedChannels.removeAll { $0.name == channelName }
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
    private var subscriptions = [SocketChannel: AnyPublisher<SocketMessage, Never>]()
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
        if let pusher = pusher, pusher.connection == .connected {
            return Just(pusher)
                .setFailureType(to: EventSocketError.self)
                .eraseToAnyPublisher()
        }
        return buildAuthenticationRequest()
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
        let filter: (SocketMessage) -> Bool = {
            return $0.channel == channel &&
            events.isEmpty ? true : (
                events + [.connected, .disconnected, .subscribed]
            ).contains($0.event)
        }
        
        if let publisher = subscriptions[channel] {
            return publisher
                .share()
                .filter(filter)
                .eraseToAnyPublisher()
        }
        
        let publisher = eventsPublisher
            .handleEvents(
                receiveCancel: {
                    DispatchQueue.main.async { [weak self] in
                        self?.unsubscribe(fromChannel: channel)
                    }
                },
                receiveRequest: { [weak self] demand in
                    guard demand > 0,
                          let self = self else { return }
                    if self.pusher == nil || self.pusher?.connection != .connected {
                        self.attemptConnection()
                            .map {
                                $0.subscribe(channel.rawValue)
                            }
                            .sink { _ in } receiveValue: {_ in}
                            .store(in: &self.cancellables)
                    }
                }
            )
            .eraseToAnyPublisher()
        
        subscriptions[channel] = publisher
        
        return publisher
            .share()
            .filter(filter)
            .eraseToAnyPublisher()
    }

    private func unsubscribe(fromChannel channel: SocketChannel) {
        pusher?.unsubscribe(channel.rawValue)
        subscriptions[channel] = nil
    }

    public func failedToSubscribeToChannel(name: String, response: URLResponse?, data: String?, error: NSError?) {
        print("Failed to subscribe to channel: \(name)")
    }

    public func subscribedToChannel(name: String) {
        eventsPublisher.send(
            .init(
                channel: SocketChannel(rawValue: name),
                event: .subscribed,
                data: nil
            )
        )
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
                    guard let channelName = item.channelName else {
                        return
                    }
                    let channel = SocketChannel(rawValue: channelName)
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
