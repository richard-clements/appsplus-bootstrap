#if canImport(UIKit) && (os(iOS) || os(tvOS) || os(macOS))

import UIKit

extension UIView {
    
    func pinConstraints(to view: UIView, margin: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin.left),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: margin.right),
            topAnchor.constraint(equalTo: view.topAnchor, constant: margin.top),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: margin.bottom)
        ])
    }
    
    func pinConstraints(to layoutGuide: UILayoutGuide, margin: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: margin.left),
            layoutGuide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: margin.right),
            topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: margin.top),
            layoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor, constant: margin.bottom)
        ])
    }
    
    func intersection(withWindowFrame frame: CGRect, offset: CGPoint = .zero) -> CGRect? {
        window?.convert(self.frame.offsetBy(dx: offset.x, dy: offset.y), from: superview).intersection(frame)
    }
}

#endif
