#if canImport(UIKit)
import UIKit

public class TextSeparatorView: UIView {
    
    private let leftSeparator = SeparatorView()
    private let rightSeparator = SeparatorView()
    private let textLabel = UILabel()
    
    public var font: UIFont! {
        get {
            textLabel.font
        }
        set {
            textLabel.font = newValue
        }
    }
    
    public var text: String? {
        get {
            textLabel.text
        }
        set {
            textLabel.text = newValue
        }
    }
    
    public var textColor: UIColor! {
        get {
            textLabel.textColor
        }
        set {
            textLabel.textColor = newValue
        }
    }
    
    public override var tintColor: UIColor! {
        didSet {
            leftSeparator.tintColor = tintColor
            rightSeparator.tintColor = tintColor
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
        textLabel.font = .appFontProvider(.smallBody)
        textLabel.textColor = tintColor
        leftSeparator.tintColor = tintColor
        rightSeparator.tintColor = tintColor
        [
            textLabel,
            leftSeparator,
            rightSeparator
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        setUpConstraints()
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            leftSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            leftSeparator.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            textLabel.leadingAnchor.constraint(equalTo: leftSeparator.trailingAnchor, constant: .margin(.small)),
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.topAnchor.constraint(equalTo: topAnchor),
            textLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            rightSeparator.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: .margin(.small)),
            rightSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
            rightSeparator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
#endif
