#if canImport(Foundation)

import Foundation

public struct Manifest: Codable, Equatable {
    public struct Asset: Codable, Equatable {
        let kind: String
        let url: String
    }
    
    public struct Metadata: Codable, Equatable {
        enum CodingKeys: String, CodingKey {
            case bundleIdentifier = "bundle-identifier"
            case bundleVersion = "bundle-version"
            case bundleBuild = "bundle-build"
            case kind
            case title
            case expirationDate = "expiration-date"
        }
        
        public let bundleIdentifier: String
        let bundleVersion: String
        public let bundleBuild: String
        public let kind: String
        public let title: String
        public let expirationDate: Date
        
        public var version: Version {
            Version(string: bundleVersion, buildName: bundleBuild)
        }
    }
    
    public struct Item: Codable, Equatable {
        let assets: [Asset]
        let metadata: Metadata
    }
    
    public let items: [Item]
}

#endif
