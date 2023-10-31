#if canImport(Foundation) && canImport(SwiftCheck)

import Foundation
import SwiftCheck

extension Gen where A == String {
    
    public static func length(in range: ClosedRange<Int>) -> Gen<String> {
        Gen<Int>
            .fromElements(in: range)
            .flatMap { length in
                String
                    .arbitrary
                    .map {
                        $0
                            .prefix(length)
                            .padding(toLength: length, withPad: " ", startingAt: 0)
                    }
            }
            .map { String($0) }
    }
    
    public static func contactNumber() -> Gen<String> {
        let allowedChars = "0123456789+ ()".map { $0 }
        return UInt
            .arbitrary
            .flatMap { length in
                sequence(
                    (0 ..< length)
                        .map { _ in Gen<Character>.fromElements(of: allowedChars) }
                )
            }
            .map { (characters: [String.Element]) in
                characters.reduce("") { result, character in
                    result + String(character)
                }
            }
    }
    
    public static func alphanumerics() -> Gen<String> {
        let upper = Gen<Character>.fromElements(in: "A"..."Z")
        let lower = Gen<Character>.fromElements(in: "a"..."z")
        let numerics = Gen<Character>.fromElements(in: "0"..."9")
        return Gen<Character>.one(of: [
            upper,
            lower,
            numerics
        ]).proliferate.map { String($0) }
    }
    
    public static func alphanumerics() -> Gen<String?> {
        let upper = Gen<Character>.fromElements(in: "A"..."Z")
        let lower = Gen<Character>.fromElements(in: "a"..."z")
        let numerics = Gen<Character>.fromElements(in: "0"..."9")
        return Gen<String?>.one(of: [.pure(nil), Gen<Character>.one(of: [
            upper,
            lower,
            numerics
        ]).proliferate.map { Optional(String($0)) }])
    }
}

#endif
