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
            setNeedsUpdateConstraints()
        }
    }
    
    var topAnchorConstraint: NSLayoutConstraint!
    var bottomAnchorConstraint: NSLayoutConstraint!
    var leadingAnchorConstraint: NSLayoutConstraint!
    var trailingAnchorConstraint: NSLayoutConstraint!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.pinConstraints(to: self)
        contentView.addSubview(retryView)
        
        retryView.translatesAutoresizingMaskIntoConstraints = false
        leadingAnchorConstraint = retryView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0)
        trailingAnchorConstraint = retryView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0)
        topAnchorConstraint = retryView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20)
        bottomAnchorConstraint = retryView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 20)
        NSLayoutConstraint.activate([
            leadingAnchorConstraint,
            trailingAnchorConstraint,
            topAnchorConstraint,
            bottomAnchorConstraint
        ])
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        retryView.removeTargets()
    }
}

#endif
