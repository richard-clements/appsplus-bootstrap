#if canImport(Foundation)

import Foundation

enum ValidationParseError: Error {
    case failedToParse
}

struct ValidationError<Field: Hashable & CaseIterable & RawRepresentable>: Equatable where Field.RawValue == String {
    let errors: [Field: [String]]
}

extension ValidationError {
    
    init(data: Data) throws {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let errors = json["errors"] as? [String: [String]]  else {
            throw ValidationParseError.failedToParse
        }
        let validationErrors: [Field: [String]] = Field.allCases.reduce(into: [Field: [String]]()) {
            $0[$1] = errors[$1.rawValue]
        }.filter { !$0.value.isEmpty }
        guard !validationErrors.isEmpty else {
            throw ValidationParseError.failedToParse
        }
        self.errors = validationErrors
    }
    
}

#endif
