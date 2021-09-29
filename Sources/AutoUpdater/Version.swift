#if canImport(Foundation)

import Foundation

public struct Version: Comparable, Codable {
    public static func < (lhs: Version, rhs: Version) -> Bool {
        lhs.indexPath < rhs.indexPath
    }
    
    public let major: Int
    public let minor: Int
    public let patch: Int
    public let build: Int
    
    public init(major: Int, minor: Int, patch: Int, build: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.build = build
    }
    
    internal init(string: String, buildName: String) {
        let components = string.split(separator: ".")
            .compactMap(String.init)
            .compactMap(Int.init)
        guard let build = Int(buildName),
              components.count == 3 else {
            self.major = 0
            self.minor = 0
            self.patch = 0
            self.build = 0
            return
        }
        self.major = components[0]
        self.minor = components[1]
        self.patch = components[2]
        self.build = build
    }
    
    private var indexPath: IndexPath {
        [major, minor, patch, build]
    }
}

#endif
