import Foundation

extension Double {
    
    public func matches(_ other: Double, accuracy: Double = 10E-5) -> Bool {
        abs(self - other) < accuracy
    }
    
}
