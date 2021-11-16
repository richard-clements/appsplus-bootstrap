#if canImport(UIKit)
import UIKit

@available(iOS 14.0, tvOS 14.0, *)
extension UIConfigurationStateCustomKey {
    public static let date: Self = .init("uk.co.appsplus.bootstrap.date")
    public static let weekday: Self = .init("uk.co.appsplus.bootstrap.weekday")
    public static let isToday: Self = .init("uk.co.appsplus.bootstrap.isToday")
    public static let hasEvent: Self = .init("uk.co.appsplus.bootstrap.hasEvents")
}

@available(iOS 14.0, tvOS 14.0, *)
extension UIConfigurationState {
    public var monthDate: MonthCalendarView.Day? {
        get { self[.date] as? MonthCalendarView.Day }
        set { self[.date] = newValue }
    }
    public var weekday: MonthCalendarView.Weekday? {
        get { self[.weekday] as? MonthCalendarView.Weekday }
        set { self[.weekday] = newValue }
    }
    public var isToday: Bool {
        get { self[.isToday] as? Bool ?? false }
        set { self[.isToday] = newValue }
    }
    public var hasEvent: Bool {
        get { self[.hasEvent] as? Bool ?? false }
        set { self[.hasEvent] = newValue }
    }
    
}

@available(iOS 14.0, tvOS 14.0, *)
public class CalendarCell: UICollectionViewCell {
    
    public var day: MonthCalendarView.Day? {
        didSet {
            if oldValue != day {
                setNeedsUpdateConfiguration()
            }
        }
    }
    
    public var weekday: MonthCalendarView.Weekday? {
        didSet {
            if oldValue != weekday {
                setNeedsUpdateConfiguration()
            }
        }
    }
    
    public var isToday: Bool = false {
        didSet {
            if oldValue != isToday {
                setNeedsUpdateConfiguration()
            }
        }
    }
    
    public var hasEvent: Bool = false {
        didSet {
            if oldValue != hasEvent {
                setNeedsUpdateConfiguration()
            }
        }
    }
    
    public override var configurationState: UICellConfigurationState {
        var configurationState = super.configurationState
        configurationState.monthDate = day
        configurationState.weekday = weekday
        configurationState.isToday = isToday
        configurationState.hasEvent = hasEvent
        return configurationState
    }
    
}

#endif
