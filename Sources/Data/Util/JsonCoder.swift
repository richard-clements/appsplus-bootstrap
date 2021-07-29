#if canImport(Foundation)

import Foundation

extension JSONDecoder {
    
    public static func strategy(convertFromSnakeCase: Bool = false, dateFormat: String? = nil) -> JSONDecoder {
        let decoder = JSONDecoder()
        if convertFromSnakeCase {
            decoder.keyDecodingStrategy = .convertFromSnakeCase
        }
        if let dateFormat = dateFormat {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_UK")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.dateFormat = dateFormat
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
        }
        return decoder
    }
    
}

extension JSONEncoder {
    
    public static func strategy(convertToSnakeCase: Bool = false, dateFormat: String? = nil) -> JSONEncoder {
        let encoder = JSONEncoder()
        if convertToSnakeCase {
            encoder.keyEncodingStrategy = .convertToSnakeCase
        }
        if let dateFormat = dateFormat {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_UK")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.dateFormat = dateFormat
            encoder.dateEncodingStrategy = .formatted(dateFormatter)
        }
        return encoder
    }
    
}

#endif
