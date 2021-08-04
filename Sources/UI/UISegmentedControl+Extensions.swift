#if canImport(UIKit)

import UIKit

extension UISegmentedControl {
    
    func setItems(_ items: [String]) {
        while numberOfSegments > items.count {
            removeSegment(at: 0, animated: false)
        }
        while numberOfSegments < items.count {
            insertSegment(withTitle: nil, at: 0, animated: false)
        }
        items.enumerated().forEach { index, title in
            setTitle(title, forSegmentAt: index)
        }
    }
    
    func setItems(_ items: [UIImage]) {
        while numberOfSegments > items.count {
            removeSegment(at: 0, animated: false)
        }
        while numberOfSegments < items.count {
            insertSegment(with: nil, at: 0, animated: false)
        }
        items.enumerated().forEach { index, image in
            setImage(image, forSegmentAt: index)
        }
    }
    
}

#endif
