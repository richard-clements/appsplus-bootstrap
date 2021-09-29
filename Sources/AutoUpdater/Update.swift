#if canImport(Foundation)

import Foundation

public enum UpdateStatus: Equatable {
    case latest
    case available(Update)
}

public struct Update: Equatable {
    public let manifest: Manifest
    public let url: URL
    public let version: Version
}

#endif
