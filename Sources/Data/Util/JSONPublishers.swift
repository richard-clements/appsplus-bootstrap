#if canImport(Foundation) && canImport(Combine)

import Foundation
import Combine

struct JSONDecodeError: LocalizedError {
    
    static let invalidArguments = JSONDecodeError(rawValue: "Error decoding data.")
    
    let rawValue: String
    var errorDescription: String? {
        rawValue
    }
}

extension JSONSerialization {
    
    public static func jsonObject(with data: Data, options: JSONSerialization.ReadingOptions) throws -> JSON {
        do {
            let value: Any = try jsonObject(with: data, options: options)
            return JSON(data: value)
        } catch {
            throw error
        }
    }
    
    public static func jsonPaginationData(with data: Data, options: JSONSerialization.ReadingOptions) throws -> Page<JSON> {
        let json: JSON = try Self.jsonObject(with: data, options: options)
        
        guard let data = json["data"]?.array,
              let currentPage = json["meta"]?["current_page"]?.integer,
              let lastPage = json["meta"]?["last_page"]?.integer else {
            throw JSONDecodeError.invalidArguments
        }
        
        return Page(data: data, meta: .init(currentPage: currentPage, lastPage: lastPage, total: json["meta"]?["total"]?.integer))
    }
    
}

extension Publisher where Output == Data {
    public func mapToJSON(options: JSONSerialization.ReadingOptions) -> AnyPublisher<JSON, Error> {
        self.mapError { $0 as Error }
            .tryMap { data -> JSON in
                do {
                    return try JSONSerialization.jsonObject(with: data, options: options)
                } catch {
                    throw JSONDecodeError.invalidArguments
                }
            }
            .eraseToAnyPublisher()
    }
    
    public func jsonPaginationData(options: JSONSerialization.ReadingOptions) -> AnyPublisher<Page<JSON>, Error> {
        self.mapToJSON(options: options)
            .tryMap { json -> Page<JSON> in
                guard let data = json["data"]?.array,
                      let currentPage = json["meta"]?["current_page"]?.integer,
                      let lastPage = json["meta"]?["last_page"]?.integer else {
                    throw JSONDecodeError.invalidArguments
                }
                return Page(data: data, meta: .init(currentPage: currentPage, lastPage: lastPage, total: json["meta"]?["total"]?.integer))
            }
            .eraseToAnyPublisher()
    }
    
}

extension Publisher where Output == JSON {
    public func guardId() -> AnyPublisher<(id: Int64, json: JSON), Error> {
        tryMap {
            guard let id = $0["id"]?.int64 else {
                throw JSONDecodeError.invalidArguments
            }
            
            return (id: id, json: $0)
        }
        .eraseToAnyPublisher()
    }
    
    public func guardKeyInt64(key: String) -> AnyPublisher<(key: Int64, json: JSON), Error> {
        tryMap {
            guard let key = $0[key]?.int64 else {
                throw JSONDecodeError.invalidArguments
            }
            
            return (key: key, json: $0)
        }
        .eraseToAnyPublisher()
    }
    
}

#endif
