#if canImport(CoreData) && canImport(Foundation)

import CoreData
import Foundation

class TestEntity: NSManagedObject {
    
}

extension TestEntity {
    
    @NSManaged var id: Int32
    @NSManaged var name: String
    
}

#endif
