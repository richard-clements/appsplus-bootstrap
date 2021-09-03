#if canImport(UIKit) && canImport(Combine)

import UIKit
import Combine

@available(iOS 13.0, tvOS 13.0, *)
class RetryCollectionCell<Control: UIControl>: UICollectionViewCell {
    
    private let retryView = RetryView<Control>()
    
    var title: String? {
        get {
            retryView.title
        }
        set {
            retryView.title = newValue
        }
    }
    
    var button: Control {
        retryView.button
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(retryView)
        retryView.pinConstraints(to: contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        retryView.removeTargets()
    }
}

#endif
