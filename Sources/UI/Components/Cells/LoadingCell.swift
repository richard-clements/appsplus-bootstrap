#if canImport(UIKit)

import UIKit

@available(iOS 13.0, tvOS 13.0, *)
public class LoadingCell: UICollectionViewCell {
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let titleLabel = UILabel()
    private var contentInset: UIEdgeInsets = .zero

    public var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
            titleLabel.isHidden = newValue == nil
        }
    }
    
    public var titleColor: UIColor! {
        get {
            titleLabel.textColor
        }
        set {
            titleLabel.textColor = newValue
        }
    }
    
    public var activityIndicatorColor: UIColor! {
        get {
            activityIndicator.color
        }
        set {
            activityIndicator.color = newValue
        }
    }
    
    private var topConstraint: NSLayoutConstraint!
    public var topMargin: CGFloat {
        get {
            topConstraint.constant
        }
        set {
            topConstraint.constant = newValue
        }
    }
    
    private var bottomConstraint: NSLayoutConstraint!
    public var bottomMargin: CGFloat {
        get {
            bottomConstraint.constant
        }
        set {
            bottomConstraint.constant = newValue
        }
    }
    
    private var verticalConstraint: NSLayoutConstraint!
    public var verticalMargin: CGFloat {
        get {
            verticalConstraint.constant
        }
        set {
            verticalConstraint.constant = newValue
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setUp(activityIndicator: activityIndicator)
        setUp(titleLabel: titleLabel)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(titleLabel)
        setUpConstraints()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp(activityIndicator: UIActivityIndicatorView) {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setUp(titleLabel: UILabel) {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.appFontProvider(.headline)
        titleLabel.textAlignment = .center
    }
    
    private func setUpConstraints() {
        topConstraint = activityIndicator.topAnchor.constraint(equalTo: contentView.topAnchor, constant: .margin(.small))
        verticalConstraint = titleLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: .margin(.medium))
        bottomConstraint = contentView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .margin(.small))
        
        NSLayoutConstraint.activate([
            topConstraint,
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            verticalConstraint,
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            bottomConstraint
        ])
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        if !activityIndicator.isAnimating {
            activityIndicator.startAnimating()
        }
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
}

#endif
