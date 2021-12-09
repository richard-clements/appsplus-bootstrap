#if canImport(UIKit)
import UIKit

@available(iOS 13.0, tvOS 13.0, *)
extension UICollectionViewDiffableDataSource {
    
    public func removeItems(_ items: [ItemIdentifierType], animated: Bool, completionHandler: @escaping () -> Void) {
        var snapshot = self.snapshot()
        snapshot.deleteItems(items)
        apply(snapshot, animatingDifferences: animated, completion: completionHandler)
    }
    
    public func removeItems(_ item: ItemIdentifierType, animated: Bool, completionHandler: @escaping () -> Void) {
        removeItems([item], animated: animated, completionHandler: completionHandler)
    }
}

#endif
