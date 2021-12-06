#if canImport(UIKit)
import UIKit

public class StackView<View: UIView>: UIView {
    
    private let stackView = UIStackView()
    
    public var arrangedSubviews: [View] {
        stackView.arrangedSubviews.compactMap { $0 as? View }
    }
    
    public var alignment: UIStackView.Alignment {
        get {
            stackView.alignment
        }
        set {
            stackView.alignment = newValue
        }
    }
    
    public var axis: NSLayoutConstraint.Axis {
        get {
            stackView.axis
        }
        set {
            stackView.axis = newValue
        }
    }
    
    public var isBaselineRelativeArrangement: Bool {
        get {
            stackView.isBaselineRelativeArrangement
        }
        set {
            stackView.isBaselineRelativeArrangement = newValue
        }
    }
    
    public var distribution: UIStackView.Distribution {
        get {
            stackView.distribution
        }
        set {
            stackView.distribution = newValue
        }
    }
    
    public var isLayoutMarginsRelativeArrangement: Bool {
        get {
            stackView.isLayoutMarginsRelativeArrangement
        }
        set {
            stackView.isLayoutMarginsRelativeArrangement = newValue
        }
    }
    
    public var spacing: CGFloat {
        get {
            stackView.spacing
        }
        set {
            stackView.spacing = newValue
        }
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
        addSubview(stackView)
        stackView.pinConstraints(to: self)
    }
    
    public func addArrangedSubview(_ view: View) {
        stackView.addArrangedSubview(view)
    }
    
    public func addArrangedSubviews(_ views: View...) {
        views.forEach(stackView.addArrangedSubview)
    }
    
    public func insertArrangedSubview(_ view: View, at index: Int) {
        stackView.insertArrangedSubview(view, at: index)
    }
    
    public func removeArrangedSubview(_ view: View) {
        stackView.removeArrangedSubview(view)
    }
    
    public func customSpacing(after view: View) -> CGFloat {
        stackView.customSpacing(after: view)
    }
    
    public func setCustomSpacing(_ spacing: CGFloat, after view: View) {
        stackView.setCustomSpacing(spacing, after: view)
    }
}

extension StackView {
    
    public func updateList(
        toCount count: Int,
        initialiser: (Int) -> View = { _ in View() },
        configuration: (Int, View) -> Void
    ) {
        guard count > 0 else {
            arrangedSubviews.forEach {
                removeArrangedSubview($0)
                $0.removeFromSuperview()
            }
            return
        }
        
        while count < arrangedSubviews.count {
            if let last = arrangedSubviews.last {
                removeArrangedSubview(last)
                last.removeFromSuperview()
            }
        }
        
        if count > arrangedSubviews.count {
            (arrangedSubviews.count ..< count).forEach {
                addArrangedSubview(initialiser($0))
            }
        }
        
        arrangedSubviews.enumerated().forEach(configuration)
    }
    
    public func updateList<ViewModel>(
        viewModels: [ViewModel],
        initialiser: (ViewModel) -> View = { _ in View() },
        configuration: (ViewModel, View) -> Void
    ) {
        updateList(toCount: viewModels.count, initialiser: {
            initialiser(viewModels[$0])
        }, configuration: {
            configuration(viewModels[$0], $1)
            stackView.bringSubviewToFront($1)
        })
    }
}

#endif
