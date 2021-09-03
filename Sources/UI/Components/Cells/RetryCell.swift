#if canImport(UIKit) && canImport(Combine)

import UIKit
import Combine

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
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(retryView)
        retryView.pinConstraints(to: contentView)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        retryView.removeTargets()
    }
}

#endif
