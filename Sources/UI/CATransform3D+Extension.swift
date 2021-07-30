#if canImport(UIKit)

import UIKit

extension CATransform3D {
    
    func setPerspective(_ perspective: CGFloat) -> CATransform3D {
        var transform = self
        transform.m34 = perspective
        return transform
    }
    
    func concatenating(_ transform: CATransform3D) -> CATransform3D {
        CATransform3DConcat(self, transform)
    }
    
}
#endif
