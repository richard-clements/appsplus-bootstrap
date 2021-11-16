#if canImport(UIKit)
import UIKit

@available(iOS 14.0, tvOS 14.0, *)
public class MonthCalendarDaysHeaderView: UIView {
    
    public var format: Format = .short {
        didSet {
            guard oldValue != format else { return }
            updateStartWeekday(connectedCalendarView?.startDay ?? .monday)
        }
    }
    public var dayNameFormatter: ((MonthCalendarView.Weekday, Format, String) -> String?)?
    public var font: UIFont = .appFontProvider(.caption1) {
        didSet {
            guard oldValue != font else { return }
            labels.forEach { $0.font = font }
        }
    }
    public override var tintColor: UIColor! {
        didSet {
            guard oldValue != tintColor else { return }
            labels.forEach { $0.textColor = tintColor }
        }
    }
    
    private let labels = (0 ..< 7).map { _ in UILabel() }
    private weak var connectedCalendarView: MonthCalendarView? {
        didSet {
            guard oldValue !== connectedCalendarView else {
                return
            }
            if let startDay = connectedCalendarView?.startDay {
                updateStartWeekday(startDay)
            }
            setNeedsLayout()
        }
    }
    private let stackView = UIStackView()
    private var stackViewLeadingConstraint: NSLayoutConstraint! {
        didSet {
            oldValue?.isActive = false
            stackViewLeadingConstraint.isActive = true
            setNeedsUpdateConstraints()
        }
    }
    private var stackViewTrailingConstraint: NSLayoutConstraint! {
        didSet {
            oldValue?.isActive = false
            stackViewTrailingConstraint.isActive = true
            setNeedsUpdateConstraints()
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let connectedCalendarView = connectedCalendarView,
           connectedCalendarView.window.map({ isDescendant(of: $0) }) ?? false {
            stackViewLeadingConstraint = stackView.leadingAnchor.constraint(equalTo: connectedCalendarView.layoutMarginsGuide.leadingAnchor)
            stackViewTrailingConstraint = stackView.trailingAnchor.constraint(equalTo: connectedCalendarView.layoutMarginsGuide.trailingAnchor)
        } else {
            stackViewLeadingConstraint = stackView.leadingAnchor.constraint(equalTo: leadingAnchor)
            stackViewTrailingConstraint = stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        }
    }
}

// MARK: Set Up

@available(iOS 14.0, tvOS 14.0, *)
extension MonthCalendarDaysHeaderView {
    
    private func commonInit() {
        setUp(stackView: stackView)
        labels.forEach {
            $0.font = font
            $0.textColor = tintColor
            $0.textAlignment = .center
            stackView.addArrangedSubview($0)
        }
        addSubview(stackView)
        setUpConstraints()
    }
    
    private func setUp(stackView: UIStackView) {
        stackView.spacing = 0
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setUpConstraints() {
        stackViewLeadingConstraint = stackView.leadingAnchor.constraint(equalTo: leadingAnchor)
        stackViewTrailingConstraint = stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: stackView.topAnchor),
            bottomAnchor.constraint(equalTo: stackView.bottomAnchor)
        ])
    }
}

@available(iOS 14.0, tvOS 14.0, *)
extension MonthCalendarDaysHeaderView {
    
    public func connect(to view: MonthCalendarView) {
        connectedCalendarView = view
    }
    
}

// MARK: Formatting

@available(iOS 14.0, tvOS 14.0, *)
extension MonthCalendarDaysHeaderView {
    
    public enum Format: Hashable {
        case letter
        case short
        case long
    }
    
    private static let dayInitials: [MonthCalendarView.Weekday: String] = [
        .monday: "M",
        .tuesday: "T",
        .wednesday: "W",
        .thursday: "T",
        .friday: "F",
        .saturday: "S",
        .sunday: "S"
    ]
    
    private static let daysShortNames: [MonthCalendarView.Weekday: String] = [
        .monday: "Mon",
        .tuesday: "Tue",
        .wednesday: "Wed",
        .thursday: "Thu",
        .friday: "Fri",
        .saturday: "Sat",
        .sunday: "Sun"
    ]
    
    private static let daysLongNames: [MonthCalendarView.Weekday: String] = [
        .monday: "Monday",
        .tuesday: "Tuesday",
        .wednesday: "Wednesday",
        .thursday: "Thursday",
        .friday: "Friday",
        .saturday: "Saturday",
        .sunday: "Sunday"
    ]
    
    private func updateStartWeekday(_ weekday: MonthCalendarView.Weekday) {
        let weekdays = (Array(weekday.rawValue ..< 7) + Array(0 ..< weekday.rawValue))
            .map { MonthCalendarView.Weekday(rawValue: $0)! }
        zip(labels, weekdays).forEach {
            $0.text = format(weekday: $1)
        }
    }
    
    private func format(weekday: MonthCalendarView.Weekday) -> String {
        let proposedName = proposedFormat(for: weekday, format: format)
        if let value = dayNameFormatter?(weekday, format, proposedName) {
            return value
        }
        return proposedName
    }
    
    private func proposedFormat(for weekday: MonthCalendarView.Weekday, format: Format) -> String {
        switch format {
        case .letter:
            return Self.dayInitials[weekday]!
        case .short:
            return Self.daysShortNames[weekday]!
        case .long:
            return Self.daysLongNames[weekday]!
        }
    }
}
#endif
