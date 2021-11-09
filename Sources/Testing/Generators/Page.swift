#if canImport(Foundation) && canImport(SwiftCheck)

import AppsPlusData
import SwiftCheck

extension Page {
    
    public static func generator(
        dataGenerator: Gen<[T]>,
        pageGenerator: Gen<Int>,
        lastPageOffset: Gen<Int> = Gen.fromElements(in: 0...5)
    ) -> Gen<Page<T>> {
        Gen.compose {
            let currentPage = $0.generate(using: pageGenerator)
            let lastPage = currentPage + $0.generate(using: lastPageOffset)
            return Page(
                data: $0.generate(using: dataGenerator),
                meta: .init(
                    currentPage: currentPage,
                    lastPage: lastPage
                )
            )
        }
    }
    
}

extension Page: Arbitrary where T: Arbitrary {
    
    public static var arbitrary: Gen<Page<T>> {
        generator(dataGenerator: T.arbitrary.proliferate, pageGenerator: Int.arbitrary.suchThat { $0 > 0 })
    }
    
}

#endif
