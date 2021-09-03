#if canImport(UIKit) && canImport(Combine)

import UIKit
import Combine

@available(iOS 13.0, tvOS 13.0, *)
class RetryView<Control: UIControl>: UIView {
    
    private let titleLabel = UILabel()
    let button = Control()
    
    var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    override var tintColor: UIColor! {
        didSet {
            titleLabel.textColor = tintColor
        }
    }
    
    var verticalMargin: CGFloat = 20
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp(titleLabel: titleLabel)
        setUp(button: button)
        addSubview(titleLabel)
        addSubview(button)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp(titleLabel: UILabel) {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.textColor = tintColor
        titleLabel.font = UIFont.appFontProvider(.headline)
        titleLabel.textAlignment = .center
    }
    
    private func setUp(button: Control) {
        button.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            button.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: verticalMargin),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            bottomAnchor.constraint(equalTo: button.bottomAnchor)
        ])
    }
    
    func removeTargets() {
        button.removeTarget(nil, action: nil, for: .touchUpInside)
    }
    
}

#endif
