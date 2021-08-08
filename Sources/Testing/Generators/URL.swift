#if canImport(Foundation) && canImport(SwiftCheck)

import Foundation
import SwiftCheck

extension URL: Arbitrary {
    
    public static var arbitrary: Gen<URL> {
        generator()
    }
    
    public static func generator(schemeGenerator: Gen<String>? = nil, hostGenerator: Gen<String>? = nil, pathGenerator: Gen<String>? = nil) -> Gen<URL> {
        Gen.compose { composer in
            let scheme = schemeGenerator.map { composer.generate(using: $0) } ?? "https"
            let host = hostGenerator.map { composer.generate(using: $0) } ?? composer.generate(using: Gen.zip(String.urlComponentGenerator(), String.urlSuffixGenerator()).map { "\($0).\($1)" })
            let path = pathGenerator.map { composer.generate(using: $0) } ?? composer.generate(using: String.pathComponentGenerator())
            return URL(string: "\(scheme)://www.\(host)/\(path)")!
        }
    }
    
}

extension String {
    
    fileprivate static func urlComponentGenerator() -> Gen<String> {
        Gen<Character>
            .fromElements(in: "a"..."z")
            .proliferateNonEmpty
            .map { String($0) }
    }
    
    fileprivate static func pathComponentGenerator() -> Gen<String> {
        Gen.fromElements(in: 0 ... 4)
            .flatMap {
                urlComponentGenerator().proliferate(withSize: $0)
            }
            .map { $0.joined(separator: "/") }
    }
    
    fileprivate static func urlSuffixGenerator() -> Gen<String> {
        Gen<String>.one(of: [
            .pure("co.uk"),
            .pure("com"),
            .pure("org")
        ])
    }
}

#endif
