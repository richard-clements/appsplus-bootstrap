#if canImport(UIKit)

import UIKit

extension UIImage {
    
    public func atSize(_ size: CGSize, isVectorImage: Bool = false, contentMode: UIView.ContentMode = .scaleAspectFill) -> UIImage {
        guard size.width > 0 && size.height > 0 else {
            return self
        }
        let imageSize: CGSize
        switch contentMode {
        case .scaleAspectFit:
            imageSize = fitImage(toSize: size, isVectorImage: isVectorImage)
        default:
            imageSize = scaleImage(toSize: size)
        }
        return UIGraphicsImageRenderer(size: imageSize).image { _ in
            draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        }
    }
    
    private func scaleImage(toSize size: CGSize) -> CGSize {
        let widthRatio = self.size.width / size.width
        let heightRatio = self.size.height / size.height
        
        var newSize = self.size
        if widthRatio > heightRatio {
            let scaleFactor = size.width/newSize.width
            newSize.width = size.width
            newSize.height *= scaleFactor
        } else {
            let scaleFactor = size.height/newSize.height
            newSize.height = size.height
            newSize.width *= scaleFactor
        }
        return newSize
    }
    
    private func fitImage(toSize size: CGSize, isVectorImage: Bool) -> CGSize {
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
        
        return newSize
    }
}

#endif
