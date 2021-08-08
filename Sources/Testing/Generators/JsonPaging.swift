#if canImport(Foundation) && canImport(SwiftCheck)

import Foundation
import SwiftCheck

public struct JsonGen {
    static func stringValue(for value: String?) -> String {
        value.map { "\"\($0)\""} ?? "null"
    }
    static func stringValue(for value: Int?) -> String {
        value.map { $0.description } ?? "null"
    }
}

public struct JsonPagingData<Item> {
    public let data: Data
    public let items: [Item]
    public let currentPage: Int
}

extension Gen {
    
    public static func jsonGenerator<Item>(itemGenerator: Gen<(String, Item)>, reachedEnd: Bool? = nil, minItems: Int? = nil, maxItems: Int? = nil) -> Gen<JsonPagingData<Item>> {
        func metaGenerator() -> Gen<(String, Int)> {
            return Gen<(String, Int)>.compose {
                let currentPage: Int = abs($0.generate())
                let to: Int = abs($0.generate())
                let hasReachedEnd = reachedEnd ?? $0.generate()
                let total: Int = hasReachedEnd ? to : $0.generate(using: Gen<Int>.fromElements(in: to + 1...to + 1000))
                return ("""
                {
                    "current_page": \(currentPage),
                    "to": \(to),
                    "total": \(total)
                }
                """, currentPage)
            }
        }
        
        return Gen<JsonPagingData<Item>>.compose {
            let generatedData = $0.generate(using: itemGenerator.proliferate(withSizeInRange: (minItems ?? 0)...(maxItems ?? 15)))
            let data = generatedData.map(\.0)
            let items = generatedData.map(\.1)
            let (meta, currentPage) = $0.generate(using: metaGenerator())
            return JsonPagingData(data: """
            {
                "data": [
                    \(data.joined(separator: ",\n\t\t"))
                ],
                "meta": \(meta)
            }
            """.data(using: .utf8)!, items: items, currentPage: currentPage)
        }
    }
}

#endif
