#if canImport(Foundation)

import Foundation

extension Bundle {
    
    public var version: Version {
        guard let versionNumber = infoDictionary?["CFBundleShortVersionString"] as? String,
              let buildNumber = infoDictionary?["CFBundleVersion"] as? String else {
            return Version(major: 0, minor: 0, patch: 0, build: 0)
        }
        return Version(string: versionNumber, buildName: buildNumber)
    }
    
    public var manifestUrl: URL? {
        (infoDictionary?["ManifestURL"] as? String).flatMap(URL.init)
    }
    
}

#endif
