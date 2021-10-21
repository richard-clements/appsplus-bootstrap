#if canImport(UIKit)
import UIKit

public class SeparatorView: UIView {
    
    public override var tintColor: UIColor! {
        didSet {
            backgroundColor = tintColor
        }
    }
    
    public init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setUpConstraints()
    }
    
    private func setUpConstraints() {
        heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
}
#endif
