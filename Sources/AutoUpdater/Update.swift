#if canImport(Foundation)

import Foundation

public enum Update: Equatable {
    case latest
    case available(Manifest)
}

#endif
