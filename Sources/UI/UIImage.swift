import UIKit

extension UIImage {
    
    public func atSize(_ size: CGSize, isVectorImage: Bool = false) -> UIImage {
        guard size.width > 0 && size.height > 0 else {
            return self
        }
        var newSize = self.size
        if isVectorImage {
            if newSize.width < size.width {
                let scaleFactor = size.width/newSize.width
                newSize.width = size.width
                newSize.height *= scaleFactor
            } else if newSize.width > size.width {
                let scaleFactor = size.width/newSize.width
                newSize.width = size.width
                newSize.height *= scaleFactor
            }
            if newSize.height > size.height {
                let scaleFactor = size.height/newSize.height
                newSize.height = size.height
                newSize.width *= scaleFactor
            }
        } else {
            if newSize.width > size.width {
                let scaleFactor = size.width/newSize.width
                newSize.width = size.width
                newSize.height *= scaleFactor
            }
            if newSize.height > size.height {
                let scaleFactor = size.height/newSize.height
                newSize.height = size.height
                newSize.width *= scaleFactor
            }
        }
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        }
    }
    
}
