#if canImport(UIKit)

import UIKit

@available(iOS 13.0, tvOS 13.0, *)
class LoadingCell: UICollectionViewCell {
    
    static var fontProvider: (UIFont.TextStyle) -> UIFont = UIFont.preferredFont
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let titleLabel = UILabel()

    var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }
    
    var titleColor: UIColor! {
        get {
            titleLabel.textColor
        }
        set {
            titleLabel.textColor = newValue
        }
    }
    
    var activityIndicatorColor: UIColor! {
        get {
            activityIndicator.color
        }
        set {
            activityIndicator.color = newValue
        }
    }
    
    var verticalMargin: CGFloat = 20
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp(activityIndicator: activityIndicator)
        setUp(titleLabel: titleLabel)
        contentView.addSubview(activityIndicator)
        contentView.addSubview(titleLabel)
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp(activityIndicator: UIActivityIndicatorView) {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setUp(titleLabel: UILabel) {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.font = Self.fontProvider(.headline)
        titleLabel.textAlignment = .center
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            activityIndicator.topAnchor.constraint(equalTo: contentView.topAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: verticalMargin),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if !activityIndicator.isAnimating {
            activityIndicator.startAnimating()
        }
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow == nil {
            activityIndicator.stopAnimating()
        }
    }
}

#endif
