#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

public enum AutoUpdaterError: Error {
    case failed
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public protocol AutoUpdaterService {
    func availableUpdate() -> AnyPublisher<Update, AutoUpdaterError>
}

#endif

