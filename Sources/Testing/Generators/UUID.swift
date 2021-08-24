import SwiftCheck
import Foundation

extension UUID: Arbitrary {
    
    public static var arbitrary: Gen<UUID> {
        UUID()
    }
    
}
