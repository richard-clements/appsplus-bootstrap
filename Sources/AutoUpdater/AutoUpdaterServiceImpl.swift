#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public class AutoUpdaterServiceImpl: AutoUpdaterService {
    
    private let session: URLSession
    private let currentVersion: Version
    private let manifestUrl: URL?
    
    public init(session: URLSession, currentVersion: Version, manifestUrl: URL?) {
        self.session = session
        self.currentVersion = currentVersion
        self.manifestUrl = manifestUrl
    }
    
    public func availableUpdate() -> AnyPublisher<UpdateStatus, AutoUpdaterError> {
        guard let manifestUrl = manifestUrl else {
            return Just(.latest)
                .setFailureType(to: AutoUpdaterError.self)
                .eraseToAnyPublisher()
        }
        let currentVersion = self.currentVersion
        return session.dataTaskPublisher(for: manifestUrl)
            .map(\.data)
            .decode(type: Manifest.self, decoder: PropertyListDecoder())
            .map {
                guard let item = $0.items.first, item.metadata.version > currentVersion else {
                    return UpdateStatus.latest
                }
                return .available(.init(manifest: $0, url: URL(string: "itms-services://?action=download-manifest&url=\(manifestUrl.absoluteString)")!, version: item.metadata.version))
            }
            .mapError { _ in AutoUpdaterError.failed }
            .eraseToAnyPublisher()
    }
    
}

#endif
