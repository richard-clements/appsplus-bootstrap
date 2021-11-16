#if canImport(UIKit)
import UIKit

@available(iOS 14.0, tvOS 14.0, *)
public struct MonthCalendarDayContentConfiguration: UIContentConfiguration, Hashable {
    
    private class View: UIView, UIContentView, UIPointerInteractionDelegate {
        
        var configuration: UIContentConfiguration = MonthCalendarDayContentConfiguration() {
            didSet {
                guard let configuration = configuration as? MonthCalendarDayContentConfiguration else {
                    return
                }
                if let oldValue = oldValue as? MonthCalendarDayContentConfiguration, oldValue == configuration {
                    return
                }
                updateConfiguration(configuration)
            }
        }
        
        private let label = UILabel()
        private let selectionBackground = UIView()
        private let indicator = UIView()
        private var indicatorCornerRadius: CornerRadius = .percentage(1) {
            didSet {
                if oldValue != indicatorCornerRadius {
                    setNeedsLayout()
                }
            }
        }
        private var selectionCornerRadius: CornerRadius = .percentage(1) {
            didSet {
                if oldValue != selectionCornerRadius {
                    setNeedsLayout()
                }
            }
        }
        private var labelWidthConstraint: NSLayoutConstraint!
        
        init() {
            super.init(frame: .zero)
            commonInit()
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
        
        private func commonInit() {
            backgroundColor = .clear
            setUp(label: label)
            setUp(indicator: indicator)
            setUp(selectionBackground: selectionBackground)
            addSubview(selectionBackground)
            addSubview(label)
            addSubview(indicator)
            setUpConstraints()
            
            
            let pointerInteraction = UIPointerInteraction(delegate: self)
            addInteraction(pointerInteraction)
        }
        
        private func setUp(label: UILabel) {
            label.isUserInteractionEnabled = false
            label.textAlignment = .center
            label.adjustsFontForContentSizeCategory = true
            label.translatesAutoresizingMaskIntoConstraints = false
            label.adjustsFontSizeToFitWidth = true
        }
        
        private func setUp(indicator: UIView) {
            indicator.isUserInteractionEnabled = false
            indicator.clipsToBounds = true
            indicator.translatesAutoresizingMaskIntoConstraints = false
        }
        
        private func setUp(selectionBackground: UIView) {
            selectionBackground.isUserInteractionEnabled = false
            selectionBackground.clipsToBounds = true
            selectionBackground.translatesAutoresizingMaskIntoConstraints = false
        }
        
        private func setUpConstraints() {
            labelWidthConstraint = selectionBackground.widthAnchor.constraint(equalToConstant: 20)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: .margin(.small)),
                trailingAnchor.constraint(greaterThanOrEqualTo: label.trailingAnchor, constant: .margin(.small)),
                label.centerXAnchor.constraint(equalTo: centerXAnchor),
                label.topAnchor.constraint(equalTo: topAnchor, constant: .margin(.small)),
                
                labelWidthConstraint,
                selectionBackground.centerXAnchor.constraint(equalTo: label.centerXAnchor),
                selectionBackground.heightAnchor.constraint(equalTo: selectionBackground.widthAnchor),
                selectionBackground.centerYAnchor.constraint(equalTo: label.centerYAnchor),
                
                indicator.widthAnchor.constraint(equalToConstant: 8),
                indicator.heightAnchor.constraint(equalToConstant: 8),
                indicator.centerXAnchor.constraint(equalTo: centerXAnchor),
                bottomAnchor.constraint(equalTo: indicator.bottomAnchor, constant: .margin(.xSmall))
            ])
        }
        
        private func updateLabelWidth(font: UIFont) {
            if font != label.font {
                label.font = font
                label.text = "99"
                labelWidthConstraint.constant = label.systemLayoutSizeFitting(CGSize(width: 100, height: 100)).width + .margin(.small)
            }
        }
        
        private func updateConfiguration(_ configuration: MonthCalendarDayContentConfiguration) {
            isHidden = configuration.day.isAccessory
            updateLabelWidth(font: configuration.calculatedTextProperties.font)
            let font = configuration.calculatedTextProperties.font
            label.font = font.withSize(min(font.pointSize, configuration.calculatedTextProperties.maxFontSize))
            label.text = configuration.day.day.description
            label.textColor = configuration.calculatedTextProperties.textColor
            indicator.isHidden = !configuration.hasEvent
            indicator.backgroundColor = configuration.calculatedIndicatorProperties.color
            indicatorCornerRadius = configuration.calculatedIndicatorProperties.cornerRadius
            selectionBackground.backgroundColor = configuration.isSelected ? configuration.calculatedTextProperties.backgroundColor : .clear
            selectionCornerRadius = configuration.calculatedTextProperties.backgroundCornerRadius
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            indicator.apply(cornerRadius: indicatorCornerRadius)
            selectionBackground.apply(cornerRadius: selectionCornerRadius)
        }
        
        func pointerInteraction(_ interaction: UIPointerInteraction, styleFor region: UIPointerRegion) -> UIPointerStyle? {
            UIPointerStyle(effect: .automatic(UITargetedPreview(view: selectionBackground)), shape: nil)
        }
        
    }
        
    fileprivate var day: MonthCalendarView.Day = MonthCalendarView.Day(day: 1, month: .init(month: 1, year: 1), isAccessory: false)
    fileprivate var isSelected: Bool = false
    fileprivate var calculatedTextProperties = TextProperties()
    fileprivate var calculatedIndicatorProperties = IndicatorProperties()
    fileprivate var hasEvent: Bool = false
    
    public var textProperties: DayConfiguration<TextProperties>
    public var indicatorProperties: DayConfiguration<IndicatorProperties>
    
    public func makeContentView() -> UIView & UIContentView {
        let view = View()
        view.configuration = self
        return view
    }
    
    public func updated(for state: UIConfigurationState) -> MonthCalendarDayContentConfiguration {
        var configuration = self
        if let day = state.monthDate {
            configuration.day = day
        }
        let isToday = state.isToday
        configuration.hasEvent = state.hasEvent
        let isSelected = (state as? UICellConfigurationState)?.isSelected ?? false
        let isWeekend = [.saturday, .sunday].contains(state.weekday)
        
        configuration.calculatedTextProperties = textProperties.configuration(
            for: state.traitCollection,
            isSelected: isSelected,
            isToday: isToday,
            isWeekend: isWeekend
        )
        configuration.calculatedIndicatorProperties = indicatorProperties.configuration(
            for: state.traitCollection,
            isSelected: isSelected,
            isToday: isToday,
            isWeekend: isWeekend
        )
        configuration.isSelected = isSelected
        return configuration
    }
    
}

@available(iOS 14.0, tvOS 14.0, *)
extension MonthCalendarDayContentConfiguration {
    
    public init(
        textProperties: DayConfiguration<TextProperties> = DayConfiguration(
            default: EventConfiguration(
                default: TraitConfiguration(
                    default: TextProperties(textColor: .black, backgroundColor: .clear)
                ),
                selected: TraitConfiguration(
                    default: TextProperties(textColor: .white, backgroundColor: .black)
                )
            ),
            today: EventConfiguration(
                default: TraitConfiguration(
                    default: TextProperties(textColor: .black, backgroundColor: .clear)
                ),
                selected: TraitConfiguration(
                    default: TextProperties(textColor: .white, backgroundColor: .black)
                )
            ),
            weekend: nil
        ),
        indicatorProperties: DayConfiguration<IndicatorProperties> = DayConfiguration(
            default: EventConfiguration(
                default: TraitConfiguration(
                    default: IndicatorProperties()
                )
            )
        )
    ) {
        self.textProperties = textProperties
        self.indicatorProperties = indicatorProperties
    }
    
    public init(tintColor: UIColor) {
        self.init(
            textProperties: DayConfiguration(
                default: EventConfiguration(
                    default: TraitConfiguration(
                        default: TextProperties(textColor: .label, backgroundColor: .clear)
                    ),
                    selected: TraitConfiguration(
                        default: TextProperties(textColor: .systemBackground, backgroundColor: .label)
                    )
                ),
                today: EventConfiguration(
                    default: TraitConfiguration(
                        default: TextProperties(textColor: tintColor, backgroundColor: .clear)
                    ),
                    selected: TraitConfiguration(
                        default: TextProperties(textColor: .systemBackground, backgroundColor: tintColor)
                    )
                ),
                weekend: nil
            )
        )
    }
}

@available(iOS 14.0, tvOS 14.0, *)
extension MonthCalendarDayContentConfiguration {
    
    public struct TextProperties: Hashable {
        var textColor: UIColor
        var font: UIFont
        var maxFontSize: CGFloat
        var backgroundColor: UIColor
        var backgroundCornerRadius: CornerRadius
        
        public init(
            textColor: UIColor = .black,
            font: UIFont = .appFontProvider(.footnote),
            maxFontSize: CGFloat = 18,
            backgroundColor: UIColor = .clear,
            backgroundCornerRadius: CornerRadius = .percentage(1)
        ) {
            self.textColor = textColor
            self.font = font
            self.maxFontSize = maxFontSize
            self.backgroundColor = backgroundColor
            self.backgroundCornerRadius = backgroundCornerRadius
        }
    }
    
    public struct IndicatorProperties: Hashable {
        var color: UIColor
        var cornerRadius: CornerRadius
        
        public init(
            color: UIColor = .gray,
            cornerRadius: CornerRadius = .percentage(1)
        ) {
            self.color = color
            self.cornerRadius = cornerRadius
        }
    }
    
    public struct DayConfiguration<Item: Hashable>: Hashable {
        public var `default`: EventConfiguration<Item>
        public var today: EventConfiguration<Item>?
        public var weekend: EventConfiguration<Item>?
        
        public init(
            `default`: MonthCalendarDayContentConfiguration.EventConfiguration<Item>,
            today: MonthCalendarDayContentConfiguration.EventConfiguration<Item>? = nil,
            weekend: MonthCalendarDayContentConfiguration.EventConfiguration<Item>? = nil
        ) {
            self.default = `default`
            self.today = today
            self.weekend = weekend
        }
        
        func configuration(
            for traitCollection: UITraitCollection,
            isSelected: Bool,
            isToday: Bool,
            isWeekend: Bool
        ) -> Item {
            let item: EventConfiguration<Item>
            if isToday {
                item = today ?? `default`
            } else if isWeekend {
                item = weekend ?? `default`
            } else {
                item = `default`
            }
            return item.configuration(for: traitCollection, isSelected: isSelected)
        }
    }
    
    public struct EventConfiguration<Item: Hashable>: Hashable {
        public var `default`: TraitConfiguration<Item>
        public var selected: TraitConfiguration<Item>?
        
        public init(
            `default`: MonthCalendarDayContentConfiguration.TraitConfiguration<Item>,
            selected: MonthCalendarDayContentConfiguration.TraitConfiguration<Item>? = nil
        ) {
            self.default = `default`
            self.selected = selected
        }
        
        func configuration(for traitCollection: UITraitCollection, isSelected: Bool) -> Item {
            let item = isSelected ? selected ?? `default` : `default`
            return item.configuration(for: traitCollection)
        }
    }
    
    public struct TraitConfiguration<Item: Hashable>: Hashable {
        public var `default`: Item
        public var lightMode: Item?
        public var darkMode: Item?
        
        public init(
            `default`: Item,
            lightMode: Item? = nil,
            darkMode: Item? = nil
        ) {
            self.default = `default`
            self.lightMode = lightMode
            self.darkMode = darkMode
        }
        
        func configuration(for traitCollection: UITraitCollection) -> Item {
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return darkMode ?? `default`
            default:
                return lightMode ?? `default`
            }
        }
    }
    
}
#endif
