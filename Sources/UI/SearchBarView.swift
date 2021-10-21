#if canImport(UIKit) && canImport(Combine)

import UIKit
import Combine
import CombineExtensions

public class SearchBarView: UIView {
    
    public struct Style {
        public var backgroundColor: UIColor = .white
        public var textFieldTintColor: UIColor = .black
        public var textColor: UIColor = .black
        public var placeholderColor: UIColor = .placeholderText
        public var imageTintColor: UIColor = .black
        public var cancelTintColor: UIColor = .black
    }
    
    enum State {
        case idle
        case searching
    }
    
    // MARK: - Cancellables
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Declarations
    private let textField = UITextField()
    private let backgroundView = UIView()
    private let cancelButton = UIButton()
    private let image = UIImageView(image: UIImage(systemName: "magnifyingglass"))
    @Published private var state = State.idle
    
    public var placeholder = "" {
        didSet {
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .font: UIFont.appFontProvider(.body),
                    .foregroundColor: style.placeholderColor
                ]
            )
        }
    }
    
    public var style: Style = Style() {
        didSet {
            backgroundView.backgroundColor = style.backgroundColor
            textField.tintColor = style.textFieldTintColor
            textField.textColor = style.textColor
            image.tintColor = style.imageTintColor
            cancelButton.tintColor = style.cancelTintColor
            
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [
                    .font: UIFont.appFontProvider(.body),
                    .foregroundColor: style.placeholderColor
                ]
            )
        }
    }
    
    public var cornerRadius: CornerRadius = .value(0) {
        didSet {
            if oldValue != cornerRadius {
                setNeedsLayout()
            }
        }
    }
    
    public var text: String? {
        get {
            textField.text
        }
        set {
            textField.text = newValue
        }
    }
    
    // MARK: - init
    public init() {
        super.init(frame: .zero)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(frame: .zero)
        commonInit()
    }
    
    private func commonInit() {
        addSubviews()
        setUpViews()
        setUpConstraints()
        bindView()
        setStyle()
    }
    
    // MARK: - Add Subviews
    private func addSubviews() {
        addSubview(backgroundView)
        backgroundView.addSubview(textField)
        backgroundView.addSubview(image)
        backgroundView.addSubview(cancelButton)
    }
    
    // MARK: - Setups
    private func setUpViews() {
        setUp(backgroundView: backgroundView)
        setUp(textField: textField)
        setUp(image: image)
        setUp(cancelButton: cancelButton)
    }
    
    private func setUp(backgroundView: UIView) {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
     }
    
    private func setUp(textField: UITextField) {
        textField.font = UIFont.appFontProvider(.body)
        textField.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setUp(image: UIImageView) {
        image.contentMode = .scaleAspectFit
        image.setContentHuggingPriority(.required, for: .horizontal)
        image.setContentHuggingPriority(.required, for: .vertical)
        image.setContentCompressionResistancePriority(.required, for: .horizontal)
        image.setContentCompressionResistancePriority(.required, for: .vertical)
        image.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setUp(cancelButton: UIButton) {
        cancelButton.isHidden = true
        cancelButton.alpha = 0
        cancelButton.setImage(UIImage(systemName: "xmark.circle.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setStyle() {
        style = Style()
    }
    
    private func bindView() {
        $state
            .sink { [unowned self] in
                animateState($0)
            }
            .store(in: &cancellables)
        
        textField
            .publisher(for: .editingDidBegin)
            .sink { [unowned self] _ in
                state = .searching
            }
            .store(in: &cancellables)
        
        textField
            .publisher(for: .editingDidEnd)
            .filter {
                $0.text?.isEmpty ?? true
            }
            .sink { [unowned self] _ in
                state = .idle
            }
            .store(in: &cancellables)
        
        cancelButton
            .publisher(for: .touchUpInside)
            .sink { [unowned self] _ in
                textField.text = ""
                textField.resignFirstResponder()
                textField.sendActions(for: .editingDidEnd)
            }
            .store(in: &cancellables)
    }

    private func animateState(_ state: State) {
        UIView.animate(withDuration: 0.3) { [unowned self] in
            switch state {
            case .idle:
                let textIsEmpty = textField.text?.isEmpty ?? true
                image.isHidden = textIsEmpty ? false : true
                cancelButton.alpha = textIsEmpty ? 0 : 1
                image.alpha = textIsEmpty ? 1 : 0
            case .searching:
                cancelButton.isHidden = false
                cancelButton.alpha = 1
                image.alpha = 0
            }
        } completion: { [unowned self] in
            if $0 {
                cancelButton.isHidden = cancelButton.alpha == 0
                image.isHidden = image.alpha == 0
            }
        }
    }
    
    public func textChangedPublisher() -> AnyPublisher<String, Never> {
        textField
            .publisher(for: .allEditingEvents)
            .compactMap { $0.text }
            .eraseToAnyPublisher()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        switch cornerRadius {
        case .value(let value):
            backgroundView.layer.cornerRadius = value
        case .percentage(let percentage):
            backgroundView.layer.cornerRadius = (bounds.height / 2) * percentage
        }
    }
    
    // MARK: - Constraints
    private func setUpConstraints() {
        backgroundView.pinConstraints(to: self)
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            textField.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: .margin(.small)),
            textField.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: .margin(.xSmall)),
            textField.trailingAnchor.constraint(equalTo: image.leadingAnchor, constant: -.margin(.xSmall)),
            textField.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -.margin(.small)),
            
            image.centerYAnchor.constraint(equalTo: centerYAnchor),
            image.widthAnchor.constraint(equalTo: image.heightAnchor),
            
            cancelButton.topAnchor.constraint(equalTo: image.topAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: image.leadingAnchor),
            cancelButton.trailingAnchor.constraint(equalTo: image.trailingAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: image.bottomAnchor)
        ])
    }
}
#endif
