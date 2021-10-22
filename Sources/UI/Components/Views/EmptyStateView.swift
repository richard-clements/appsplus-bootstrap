#if canImport(UIKit)

import UIKit

@available(iOS 13.0, tvOS 13.0, *)
public class EmptyStateView<Control: UIControl>: UIView {
    
    public var image: UIImage? {
        get {
            imageView.image
        }
        set {
            imageView.image = newValue
            imageView.isHidden = newValue == nil
        }
    }
    public var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
            titleLabel.isHidden = newValue == nil
        }
    }
    public var message: String? {
        get {
            messageLabel.text
        }
        set {
            messageLabel.text = newValue
            messageLabel.isHidden = newValue == nil
        }
    }
    public var maxWidth: CGFloat {
        get {
            widthAnchorConstraint.constant
        }
        set {
            widthAnchorConstraint.constant = newValue
            setNeedsUpdateConstraints()
        }
    }
    public var margin: UIEdgeInsets {
        get {
            UIEdgeInsets(top: topAnchorConstraint.constant, left: leadingAnchorConstraint.constant, bottom: bottomAnchorConstraint.constant, right: trailingAnchorConstraint.constant)
        }
        set {
            stackView.setCustomSpacing(newValue.bottom * 2, after: imageView)
            stackView.setCustomSpacing(newValue.bottom, after: textStackView)
            topAnchorConstraint.constant = newValue.top
            bottomAnchorConstraint.constant = newValue.bottom
            leadingAnchorConstraint.constant = newValue.left
            trailingAnchorConstraint.constant = newValue.right
            setNeedsUpdateConstraints()
        }
    }
    public override var tintColor: UIColor! {
        didSet {
            titleLabel.textColor = tintColor
            messageLabel.textColor = tintColor
        }
    }
    public let button = Control()
    public var shouldHideButton = false
    
    private let imageView = UIImageView(frame: CGRect())
    private let textStackView = UIStackView()
    private let titleLabel = UILabel(frame: CGRect())
    private let messageLabel = UILabel(frame: CGRect())
    private let stackView = UIStackView(frame: CGRect())
    private var widthAnchorConstraint: NSLayoutConstraint!
    private var topAnchorConstraint: NSLayoutConstraint!
    private var leadingAnchorConstraint: NSLayoutConstraint!
    private var trailingAnchorConstraint: NSLayoutConstraint!
    private var bottomAnchorConstraint: NSLayoutConstraint!
    
    public init() {
        super.init(frame: .zero)
        
        setUp(imageView: imageView)
        setUp(titleLabel: titleLabel)
        setUp(messageLabel: messageLabel)
        setUp(button: button)
        setUp(textStackView: textStackView)
        setUp(stackView: stackView)
        addSubview(stackView)
        
        setUpConstraints()
    }
    
    // MARK: - Setup
    
    private func setUp(imageView: UIImageView) {
        imageView.contentMode = .scaleAspectFit
    }
    
    private func setUp(titleLabel: UILabel) {
        titleLabel.font = UIFont.appFontProvider(.headline)
        titleLabel.textColor = tintColor
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
    }
    
    private func setUp(messageLabel: UILabel) {
        messageLabel.font = UIFont.appFontProvider(.smallBody)
        messageLabel.textColor = tintColor
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
    }
    
    private func setUp(textStackView: UIStackView) {
        textStackView.axis = .vertical
        textStackView.alignment = .center
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(messageLabel)
    }
    
    private func setUp(stackView: UIStackView) {
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(textStackView)
        stackView.addArrangedSubview(button)
        stackView.setCustomSpacing(20, after: imageView)
        stackView.setCustomSpacing(10, after: textStackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setUp(button: Control) {
        button.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Constraints
    
    private func setUpConstraints() {
        stackView.pinConstraints(to: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Auto pin an empty view to a parent
    ///
    /// Auto pins the empty view to the parent view with the following constraints:
    /// - Max width of 200
    /// - Display in the center of the parent view (taking into account the safe area layout guide for vertical only)
    /// - Top and bottom anchors can not exceed the vertical margin of the parent view
    /// - Leading and trailing anchors can not exceed the horizontal margin of the parent view
    /// - Parameter view: The parent view
    public func pinConstraints(to view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchorConstraint = widthAnchor.constraint(lessThanOrEqualToConstant: 200)
        
        topAnchorConstraint = topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: 10)
        leadingAnchorConstraint = leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20)
        trailingAnchorConstraint = view.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: 20)
        bottomAnchorConstraint = view.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: 10)
        
        NSLayoutConstraint.activate([
            topAnchorConstraint,
            leadingAnchorConstraint,
            trailingAnchorConstraint,
            bottomAnchorConstraint,
            widthAnchorConstraint,
            centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
}

#endif
