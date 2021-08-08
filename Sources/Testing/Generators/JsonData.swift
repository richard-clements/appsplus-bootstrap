#if canImport(Foundation) && canImport(SwiftCheck)

import Foundation
import SwiftCheck

public struct JsonDataHolder<Item: Codable> {
    public let data: Data
    public let items: Item
}

extension Gen {
    
    public static func jsonDataHolderGenerator<Item: Codable>(itemGenerator: Gen<(String, Item)>) -> Gen<JsonDataHolder<Item>> {
        return Gen<JsonDataHolder<Item>>.compose {
            let generatedData = $0.generate(using: itemGenerator)
            let data = generatedData.0
            let items = generatedData.1
            
            return JsonDataHolder(data: """
            {
                "data": \(data)
            }
            """.data(using: .utf8)!, items: items)
        }
    }
}

#endif
