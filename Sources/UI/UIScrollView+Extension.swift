#if canImport(UIKit) && (os(iOS) || os(tvOS) || os(macOS))

import UIKit

@available(iOS 13.0, tvOS 13.0, *)
extension UIScrollView {
    
    func isScrolledToBottom() -> Bool {
        return distanceFromBottom() >= 0
    }
    
    func distanceFromBottom() -> CGFloat {
        contentOffset.y + bounds.height - contentSize.height - adjustedContentInset.bottom
    }
    
}

extension UIView {
    
    fileprivate func lastIndexPath(numberOfSections: Int, numberOfItems: (Int) -> Int) -> IndexPath? {
        (0 ..< numberOfSections)
            .map { ($0, (0 ..< numberOfItems($0))) }
            .filter { !$0.1.isEmpty }
            .last
            .flatMap {
                guard let item = $1.last else {
                    return nil
                }
                return IndexPath(item: item, section: $0)
            }
    }
    
}

extension UITableView {
    
    func lastIndexPath() -> IndexPath? {
        lastIndexPath(numberOfSections: numberOfSections, numberOfItems: numberOfRows)
    }
    
    func isLastItemVisible() -> Bool {
        lastIndexPath().map { indexPathsForVisibleRows?.contains($0) == true } ?? false
    }
    
}

extension UICollectionView {
    
    func lastIndexPath() -> IndexPath? {
        lastIndexPath(numberOfSections: numberOfSections, numberOfItems: numberOfItems)
    }
    
    func isLastItemVisible() -> Bool {
        lastIndexPath().map { indexPathsForVisibleItems.contains($0) } ?? false
    }
    
}

#endif
