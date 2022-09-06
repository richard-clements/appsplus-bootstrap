#if canImport(UIKit) && (os(iOS) || os(tvOS) || os(macOS))

import UIKit

extension UIView {
    
    public func pinConstraints(to view: UIView, margin: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin.left),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: margin.right),
            topAnchor.constraint(equalTo: view.topAnchor, constant: margin.top),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: margin.bottom)
        ])
    }
    
    public func pinConstraints(to layoutGuide: UILayoutGuide, margin: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: margin.left),
            layoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: margin.right),
            topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: margin.top),
            layoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor, constant: margin.bottom)
        ])
    }
    
    public func intersection(
        withWindowFrame frame: CGRect,
        offset: CGPoint = .zero,
        topMargin: CGFloat = 0,
        leftMargin: CGFloat = 0,
        bottomMargin: CGFloat = 0,
        rightMargin: CGFloat = 0
    ) -> CGRect? {
        window?
            .convert(self.frame.offsetBy(dx: offset.x, dy: offset.y), from: superview)
            .intersection(frame)
            .inset(by: UIEdgeInsets(top: -topMargin, left: -leftMargin, bottom: -bottomMargin, right: -rightMargin))
    }
    
    public func pinToBottom(
        of view: UIView,
        bottomMargin: CGFloat = 0,
        safeMargin: CGFloat = 0
    ) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: bottomMargin)
        ])
        
        let safeConstraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor, constant: safeMargin)
        safeConstraint.priority = .defaultHigh
        safeConstraint.isActive = true
    }
}

#endif
