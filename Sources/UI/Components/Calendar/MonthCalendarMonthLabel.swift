#if canImport(UIKit) && canImport(Combine)
import UIKit
import Combine

@available(iOS 14.0, tvOS 14.0, *)
public class MonthCalendarMonthLabel: UIView {
    
    public enum Transition {
        case slideBackwards
    }
    
    private let labelOne = UILabel()
    private let labelTwo = UILabel()
    private var deltaCancellable: AnyCancellable?
    private var currentDayCancellable: AnyCancellable?
    private var labelLeadingConstraint: NSLayoutConstraint! {
        didSet {
            oldValue?.isActive = false
            labelLeadingConstraint.isActive = true
        }
    }
    
    public var transition: Transition = .slideBackwards
    
    public var format: [Format] = [
        .month(format: .long),
        .year(format: .long, visibility: .onlyWhenDifferent)
    ] {
        didSet {
            guard oldValue != format else { return }
            if let month = connectedCalendarView?.currentMonth {
                updateMonth(month)
            }
        }
    }
    public var monthNameFormatter: ((MonthCalendarView.Month, MonthFormat, String) -> String?)?
    public var yearNameFormatter: ((MonthCalendarView.Month, Int, YearFormat, YearVisibility, String) -> String?)?
    public var font: UIFont = .appFontProvider(.title3) {
        didSet {
            guard oldValue != font else { return }
            labelOne.font = font
            labelTwo.font = font
        }
    }
    public override var tintColor: UIColor! {
        didSet {
            guard oldValue != tintColor else { return }
            labelOne.textColor = tintColor
            labelTwo.textColor = tintColor
        }
    }
    private weak var connectedCalendarView: MonthCalendarView? {
        didSet {
            guard oldValue !== connectedCalendarView else {
                return
            }
            deltaCancellable = connectedCalendarView?.$currentMonth
                .sink { [unowned self] in
                    updateMonth($0)
                }
            currentDayCancellable = connectedCalendarView?.$today
                .sink { [unowned self] _ in
                    updateMonth(connectedCalendarView?.currentMonth)
                }
            setNeedsLayout()
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
        setUp(label: labelOne)
        setUp(label: labelTwo)
        addSubview(labelOne)
        addSubview(labelTwo)
        setUpConstraints()
    }
    
    private func setUp(label: UILabel) {
        label.font = font
        label.textColor = tintColor
        label.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setUpConstraints() {
        labelLeadingConstraint = labelOne.leadingAnchor.constraint(equalTo: leadingAnchor)
        NSLayoutConstraint.activate([
            labelOne.topAnchor.constraint(equalTo: topAnchor),
            labelOne.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelOne.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            labelTwo.topAnchor.constraint(equalTo: topAnchor),
            labelTwo.leadingAnchor.constraint(equalTo: labelOne.leadingAnchor),
            labelTwo.trailingAnchor.constraint(equalTo: trailingAnchor),
            labelTwo.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let connectedCalendarView = connectedCalendarView,
           connectedCalendarView.window.map({ labelOne.isDescendant(of: $0)}) ?? false {
            labelLeadingConstraint = labelOne.leadingAnchor.constraint(equalTo: connectedCalendarView.layoutMarginsGuide.leadingAnchor)
        } else {
            labelLeadingConstraint = labelOne.leadingAnchor.constraint(equalTo: leadingAnchor)
        }
    }
}

@available(iOS 14.0, tvOS 14.0, *)
extension MonthCalendarMonthLabel {
    
    private func updateMonth(_ month: MonthCalendarView.MonthDelta?) {
        guard let month = month else {
            labelOne.text = nil
            labelTwo.text = nil
            return
        }
        
        switch transition {
        case .slideBackwards:
            labelTwo.alpha = month.delta
            let labelTwoScale = max(0, min(1, 0.9 + 0.1*month.delta))
            labelTwo.transform = CGAffineTransform(scaleX: labelTwoScale, y: labelTwoScale)
            
            let labelOneMaxX = labelOne.center.x + (labelOne.bounds.width / 2)
            labelOne.alpha = 1 - month.delta
            labelOne.transform = CGAffineTransform(translationX: -(month.delta * labelOneMaxX), y: 0)
        }
        labelOne.text = format(month: month.currentMonth, format: format)
        labelTwo.text = format(month: month.nextMonth, format: format)
    }
    
}

@available(iOS 14.0, tvOS 14.0, *)
extension MonthCalendarMonthLabel {
    
    public func connect(to view: MonthCalendarView) {
        connectedCalendarView = view
    }
    
}

// MARK: Formatting

@available(iOS 14.0, tvOS 14.0, *)
extension MonthCalendarMonthLabel {
    
    public enum MonthFormat: Hashable {
        case letter
        case short
        case long
    }
    
    public enum YearFormat: Hashable {
        case short
        case long
    }
    
    public enum YearVisibility: Hashable {
        case newYear
        case onlyWhenDifferent
        case always
    }
    
    public enum Format: Hashable {
        case month(format: MonthFormat)
        case year(format: YearFormat, visibility: YearVisibility)
    }
    
    private static let monthLetters: [Int: String] = [
        1: "J",
        2: "F",
        3: "M",
        4: "A",
        5: "M",
        6: "J",
        7: "J",
        8: "A",
        9: "S",
        10: "O",
        11: "N",
        12: "D"
    ]
    
    private static let monthShortNames: [Int: String] = [
        1: "Jan",
        2: "Feb",
        3: "Mar",
        4: "Apr",
        5: "May",
        6: "Jun",
        7: "Jul",
        8: "Aug",
        9: "Sep",
        10: "Oct",
        11: "Nov",
        12: "Dec"
    ]
    
    private static let monthLongNames: [Int: String] = [
        1: "January",
        2: "February",
        3: "March",
        4: "April",
        5: "May",
        6: "June",
        7: "July",
        8: "August",
        9: "September",
        10: "October",
        11: "November",
        12: "December"
    ]
    
    private func format(month: MonthCalendarView.Month, format: [Format]) -> String {
        format.map {
            switch $0 {
            case .month(format: let monthFormat):
                return formatMonthName(month, format: monthFormat)
            case .year(format: let yearFormat, visibility: let visibility):
                return formatYearName(
                    month: month,
                    currentYear: connectedCalendarView?.today.month.year ?? 0,
                    format: yearFormat,
                    visibility: visibility
                )
            }
        }
        .filter { !$0.isEmpty }
        .joined(separator: " ")
    }
    
    private func formatMonthName(_ month: MonthCalendarView.Month, format: MonthFormat) -> String {
        let proposedName: String
        switch format {
        case .letter:
            proposedName = Self.monthLetters[month.month] ?? ""
        case .short:
            proposedName = Self.monthShortNames[month.month] ?? ""
        case .long:
            proposedName = Self.monthLongNames[month.month] ?? ""
        }
        
        if let value = monthNameFormatter?(month, format, proposedName) {
            return value
        }
        return proposedName
    }
    
    private func formatYearName(
        month: MonthCalendarView.Month,
        currentYear: Int,
        format: YearFormat,
        visibility: YearVisibility
    ) -> String {
        let proposedName: String
        let shouldShowYear: Bool
        switch visibility {
        case .newYear:
            shouldShowYear = month.month == 1
        case .onlyWhenDifferent:
            shouldShowYear = month.year != currentYear
        case .always:
            shouldShowYear = true
        }
        if shouldShowYear {
            switch format {
            case .short:
                proposedName = String(month.year.description.suffix(2))
            case .long:
                proposedName = month.year.description
            }
        } else {
            proposedName = ""
        }
        
        if let value = yearNameFormatter?(month, currentYear, format, visibility, proposedName) {
            return value
        }
        return proposedName
    }
}

#endif
