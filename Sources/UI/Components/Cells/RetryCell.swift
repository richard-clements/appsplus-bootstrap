#if canImport(UIKit)

import UIKit

@available(iOS 13.0, tvOS 13.0, *)
public class RetryCell<Control: UIControl>: UICollectionViewCell {
    
    private let retryView = RetryView<Control>()
    
    public var title: String? {
        get {
            retryView.title
        }
        set {
            retryView.title = newValue
        }
    }
    
    public var button: Control {
        retryView.button
    }
    
    public var verticalMargin: CGFloat {
        get {
            retryView.verticalMargin
        }
        set {
            retryView.verticalMargin = newValue
            topAnchorConstraint.constant = newValue
            bottomAnchorConstraint.constant = newValue
        }
    }
    
    var topAnchorConstraint: NSLayoutConstraint!
    var bottomAnchorConstraint: NSLayoutConstraint!
    var leadingAnchorConstraint: NSLayoutConstraint!
    var trailingAnchorConstraint: NSLayoutConstraint!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(retryView)
        
        retryView.translatesAutoresizingMaskIntoConstraints = false
        leadingAnchorConstraint = retryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: margin.left),
        trailingAnchorConstraint = retryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: margin.right),
        topAnchorConstraint = retryView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: margin.top),
        bottomAnchorConstraint = retryView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: margin.bottom)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        retryView.removeTargets()
    }
}

#endif
