#if canImport(Foundation) && canImport(SwiftCheck)

import Foundation
import SwiftCheck
import AppsPlusData

extension ValidationError: Arbitrary {
    
    public static var arbitrary: Gen<ValidationError<Field>> {
        Gen
            .fromElements(of: Array(Field.allCases))
            .proliferate(withSizeInRange: 1 ... (Field.allCases.count))
            .flatMap { field in
                Gen.compose { composer in
                    Set(field).reduce(into: [Field: [String]]()) {
                        let errors = Gen.alphanumerics().proliferate(withSizeInRange: 1 ... 3)
                        $0[$1] = composer.generate(using: errors)
                    }
                }
            }
            .map {
                ValidationError<Field>(errors: $0)
            }
    }
    
}

extension ValidationError {
    
    public func json() -> Data {
        let fieldsJson: String = errors.map {
            """
            "\($0.key.rawValue)": [
                \($0.value.map { "\"\($0)\"" }.joined(separator: ",\n"))
            ]
            """
        }.joined(separator: ",\n")
        return """
        {
            "errors": {
                \(fieldsJson)
            }
        }
        """.data(using: .utf8)!
    }
    
}

extension ValidationError {
    
    public static func jsonGenerator() -> Gen<(ValidationError, Data)> {
        arbitrary.map {
            ($0, $0.json())
        }
    }
    
}

#endif
