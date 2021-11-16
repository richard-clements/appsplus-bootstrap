#if canImport(UIKit)

import UIKit

@available(iOS 14.0, tvOS 14.0, *)
public class MonthCalendarLayout: UICollectionViewCompositionalLayout {
    
    public static func layout(
        forItemHeight itemHeight: MonthCalendarView.ItemHeight,
        pageSize: Int,
        axis: MonthCalendarView.Axis,
        layoutMargins: UIEdgeInsets
    ) -> MonthCalendarLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/7), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupHeight: NSCollectionLayoutDimension
        switch itemHeight {
        case .fixed(height: let height):
            groupHeight = .absolute(height)
        case .fractionalWidth(fraction: let fraction):
            groupHeight = .fractionalWidth(fraction / 7)
        }
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: groupHeight)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: layoutMargins.left, bottom: 0, trailing: layoutMargins.right)
        
        let layoutConfiguration = UICollectionViewCompositionalLayoutConfiguration()
        let section = NSCollectionLayoutSection(group: group)
        if axis == .horizontal {
            section.orthogonalScrollingBehavior = .groupPaging
            layoutConfiguration.scrollDirection = .horizontal
        } else {
            layoutConfiguration.scrollDirection = .vertical
        }
        
        let layout = MonthCalendarLayout(section: section)
        layout.configuration = layoutConfiguration
        layout.itemHeight = itemHeight
        layout.pageSize = pageSize
        layout.axis = axis
        return layout
    }
    
    private var scrollDelta: CGSize?
    private var lastPrepend: Date?
    private var itemHeight: MonthCalendarView.ItemHeight = .fixed(height: 0)
    private var shouldPrepend = true
    private var shouldAppend = true
    private var pageSize = 0
    private var isInitialised = false
    private var axis: MonthCalendarView.Axis = .horizontal
    private var currentHeight: CGFloat = 0
    public var prependSectionsHandler: ((@escaping () -> Void) -> Void)?
    public var appendSectionsHandler: ((@escaping () -> Void) -> Void)?
    public var layoutHeightUpdateHandler: ((CGFloat) -> Void)?
    public var currentSectionDeltaHandler: ((Int, Int, CGFloat) -> Void)?
    
    public override func prepare() {
        super.prepare()
        if let scrollDelta = scrollDelta,
           let collectionView = collectionView {
            collectionView.contentOffset = CGPoint(x: collectionView.contentOffset.x + scrollDelta.width, y: collectionView.contentOffset.y + scrollDelta.height)
            switch collectionView.panGestureRecognizer.state {
            case .began, .changed:
                break
            default:
                recalibrate()
            }
        }
        scrollDelta = nil
    }
    
    public func recalibrate() {
        guard let collectionView = collectionView else {
            return
        }
        switch axis {
        case .horizontal:
            let offset = collectionView.contentOffset.x + collectionView.bounds.width/2
            let section = floor(offset / collectionView.bounds.width)
            collectionView.setContentOffset(CGPoint(x: section * collectionView.bounds.width, y: 0), animated: true)
        case .vertical:
            let layoutAttributes = layoutAttributesForElements(in: CGRect(x: 0, y: collectionView.bounds.minY, width: collectionView.bounds.height, height: collectionView.bounds.height)) ?? []
            let minSection = layoutAttributes.min { $0.indexPath < $1.indexPath }?.indexPath.section
            let minItem = minSection.flatMap {
                layoutAttributesForItem(at: IndexPath(item: 0, section: $0))
            }?.frame.minY ?? 0
            collectionView.setContentOffset(CGPoint(x: 0, y: minItem), animated: true)
        }
        
    }
    
    public func initialised() {
        isInitialised = true
        if let collectionView = collectionView {
            switch axis {
            case .horizontal:
                horizontalUpdateHeight(for: collectionView.bounds)
            case .vertical:
                verticalUpdateHeight(for: collectionView.bounds)
            }
        }
    }
    
    private func height(forRowCount rowCount: CGFloat) -> CGFloat {
        switch itemHeight {
        case .fixed(height: let height):
            return rowCount * height
        case .fractionalWidth(fraction: let fraction):
            return (fraction / 7) * rowCount * (collectionView?.bounds.width ?? 0)
        }
    }
    
    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        switch axis {
        case .horizontal:
            return horizontalShouldInvalidateLayout(forBoundsChange: newBounds)
        case .vertical:
            return verticalShouldInvalidateLayout(forBoundsChange: newBounds)
        }
    }
    
    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        switch axis {
        case .horizontal:
            return horizontalTargetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        case .vertical:
            return verticalTargetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
    }
    
    private func canAppend() -> Bool {
        shouldAppend
    }
    
    private func append() {
        guard canAppend() else { return }
        appendSectionsHandler? { [weak self] in
            self?.shouldAppend = true
        }
    }
    
    private func canPrepend() -> Bool {
        (shouldPrepend && lastPrepend.map { Date().timeIntervalSince($0) > 0.5 } ?? true)
    }
    
    private func prepend() {
        guard canPrepend() else { return }
        let previousContentSize = collectionViewContentSize
        shouldPrepend = false
        prependSectionsHandler? { [weak self] in
            guard let self = self else { return }
            self.scrollDelta = CGSize(
                width: self.collectionViewContentSize.width - previousContentSize.width,
                height: self.collectionViewContentSize.height - previousContentSize.height
            )
            self.invalidateLayout()
            self.shouldPrepend = true
            self.lastPrepend = Date()
        }
    }
}

// MARK: Horizontal Scrolling

@available(iOS 14.0, tvOS 14.0, *)
extension MonthCalendarLayout {
    
    private func horizontalUpdateHeight(for bounds: CGRect) {
        guard shouldPrepend else { return }
        let currentSection = Int(floor(bounds.minX / bounds.width))
        let nextSection = currentSection + 1
        
        guard let collectionView = collectionView, collectionView.numberOfSections > nextSection else {
            return
        }
        
        let delta = bounds.minX.truncatingRemainder(dividingBy: bounds.width) / bounds.width
        let previousWeeksCount = ceil(CGFloat(collectionView.numberOfItems(inSection: currentSection)) / 7)
        let nextWeeksCount = ceil(CGFloat(collectionView.numberOfItems(inSection: nextSection)) / 7)
        
        let currentHeight = height(forRowCount: previousWeeksCount)
        let nextHeight = height(forRowCount: nextWeeksCount)
        let adjustedHeight = (currentHeight * (1 - delta)) + (nextHeight * delta)
        
        self.currentHeight = adjustedHeight
        layoutHeightUpdateHandler?(adjustedHeight)
        currentSectionDeltaHandler?(currentSection, nextSection, delta)
    }
    
    private func horizontalShouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView, collectionView.dataSource != nil,
              newBounds.width > 0,
              isInitialised else {
            return super.shouldInvalidateLayout(forBoundsChange: newBounds)
        }
        
        let currentSection = Int(floor(newBounds.minX / newBounds.width))
        
        if currentSection < pageSize {
            prepend()
        }
        
        if currentSection > collectionView.numberOfSections - pageSize {
            append()
        }
        
        horizontalUpdateHeight(for: newBounds)
        
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
    
    private func horizontalTargetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return proposedContentOffset
        }
        
        let minCurrentSection = floor(collectionView.contentOffset.x / collectionView.bounds.width)
        let maxCurrentSection = floor((collectionView.contentOffset.x + collectionView.bounds.width) / collectionView.bounds.width)
        
        let nearestSection: CGFloat
        
        if velocity.x > 0 {
            nearestSection = minCurrentSection + 1
        } else if velocity.x < 0 {
            nearestSection = maxCurrentSection - 1
        } else {
            let sectionDelta = (proposedContentOffset.x.truncatingRemainder(dividingBy: collectionView.bounds.width)) / collectionView.bounds.width
            let previousSection = floor(proposedContentOffset.x / collectionView.bounds.width)
            if sectionDelta > 0.5 {
                nearestSection = previousSection + 1
            } else {
                nearestSection = previousSection
            }
        }
        
        let correctedSection = max(0, min(CGFloat(collectionView.numberOfSections) - 1, nearestSection))
        return CGPoint(x: correctedSection * collectionView.bounds.width, y: 0)
    }
}

// MARK: Vertical Scrolling

@available(iOS 14.0, tvOS 14.0, *)
extension MonthCalendarLayout {
    
    private func verticalUpdateHeight(for bounds: CGRect) {
        guard shouldPrepend else { return }
        let layoutAttributes = self.layoutAttributesForElements(in: bounds) ?? []
        let currentSection = layoutAttributes.min { $0.indexPath < $1.indexPath }?.indexPath.section ?? 0
        let currentSectionLastItem = layoutAttributes
            .filter { $0.indexPath.section == currentSection }
            .max { $0.indexPath < $1.indexPath }
        
        let nextSection = currentSection + 1
        
        guard let collectionView = collectionView, collectionView.numberOfSections > nextSection else {
            return
        }
        
        let previousWeeksCount = ceil(CGFloat(collectionView.numberOfItems(inSection: currentSection)) / 7)
        let nextWeeksCount = ceil(CGFloat(collectionView.numberOfItems(inSection: nextSection)) / 7)
        
        let currentHeight = height(forRowCount: previousWeeksCount)
        let nextHeight = height(forRowCount: nextWeeksCount)
        
        let delta = min(1, max(0, 1 - ((currentSectionLastItem?.frame.maxY ?? 0) - bounds.minY) / currentHeight))
        
        let adjustedHeight = (currentHeight * (1 - delta)) + (nextHeight * delta)
        
        self.currentHeight = adjustedHeight
        layoutHeightUpdateHandler?(adjustedHeight)
        currentSectionDeltaHandler?(currentSection, nextSection, delta)
    }
    
    private func verticalShouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView, collectionView.dataSource != nil,
              newBounds.width > 0,
              isInitialised else {
            return super.shouldInvalidateLayout(forBoundsChange: newBounds)
        }
        
        let layoutAttributes = self.layoutAttributesForElements(in: newBounds) ?? []
        let currentSection = layoutAttributes.min { $0.indexPath < $1.indexPath }?.indexPath.section ?? 0
        
        if currentSection < pageSize {
            prepend()
        }
        
        if currentSection > collectionView.numberOfSections - pageSize {
            append()
        }
        
        verticalUpdateHeight(for: newBounds)
        
        return super.shouldInvalidateLayout(forBoundsChange: newBounds)
    }
    
    private func verticalTargetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {
            return proposedContentOffset
        }
        
        let layoutAttributes = self.layoutAttributesForElements(in: collectionView.bounds) ?? []
        
        let minCurrentSection = layoutAttributes.min { $0.indexPath < $1.indexPath }?.indexPath.section ?? 0
        
        let maxCurrentSection = layoutAttributes
            .filter { $0.frame.origin.y < collectionView.bounds.minY + currentHeight }
            .max { $0.indexPath < $1.indexPath }?.indexPath.section ?? 0
        
        let nearestSection: Int
        
        if velocity.y > 0 {
            nearestSection = minCurrentSection + 1
        } else if velocity.y < 0 {
            nearestSection = maxCurrentSection - 1
        } else {
            let currentSectionLastItem = layoutAttributes
                .filter { $0.indexPath.section == minCurrentSection }
                .max { $0.indexPath < $1.indexPath }
            
            let sectionDelta = min(1, max(0, 1 - ((currentSectionLastItem?.frame.maxY ?? 0) - collectionView.bounds.minY) / currentHeight))
            
            if sectionDelta > 0.5 {
                nearestSection = minCurrentSection + 1
            } else {
                nearestSection = minCurrentSection
            }
        }
        
        return layoutAttributesForItem(at: IndexPath(item: 0, section: nearestSection))?.frame.origin ?? proposedContentOffset
    }
}


#endif
