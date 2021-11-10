#if canImport(Foundation) && canImport(SwiftCheck)

import AppsPlusData
import SwiftCheck

extension Page {
    
    public static func generator(
        dataGenerator: Gen<[T]>,
        pageGenerator: Gen<Int> = Int.arbitrary.suchThat { $0 > 0 },
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
    
    public static func generator(
        dataGenerator: Gen<[T]>,
        pageGenerator: Gen<Int> = Int.arbitrary.suchThat { $0 > 0 },
        hasNextPageGenerator: Gen<Bool> = Bool.arbitrary
    ) -> Gen<Page<T>> {
        generator(
            dataGenerator: dataGenerator,
            pageGenerator: pageGenerator,
            lastPageOffset: hasNextPageGenerator.flatMap {
                $0 ? .pure(1) : Gen.fromElements(in: 0...5)
            }
        )
    }
    
}

extension Page: Arbitrary where T: Arbitrary {
    
    public static func generator(
        pageGenerator: Gen<Int> = Int.arbitrary.suchThat { $0 > 0 },
        lastPageOffset: Gen<Int> = Gen.fromElements(in: 0...5)
    ) -> Gen<Page<T>> {
        generator(
            dataGenerator: T.arbitrary.proliferate(withSizeInRange: 0...10),
            pageGenerator: pageGenerator,
            lastPageOffset: lastPageOffset
        )
    }
    
    public static func hasNextPageGenerator(
        pageGenerator: Gen<Int> = Int.arbitrary.suchThat { $0 > 0 },
        hasNextPageGenerator: Gen<Bool>
    ) -> Gen<Page<T>> {
        generator(
            dataGenerator: T.arbitrary.proliferate(withSizeInRange: 0...10),
            pageGenerator: pageGenerator,
            hasNextPageGenerator: hasNextPageGenerator
        )
    }
    
    public static var arbitrary: Gen<Page<T>> {
        generator()
    }
    
}

#endif
