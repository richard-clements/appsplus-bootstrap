#if canImport(UIKit) && canImport(Combine)
import UIKit
import Combine

@available(iOS 14.0, tvOS 14.0, *)
public class MonthCalendarView: UIView {
    
    private enum CodingKeys: String {
        case axis
        case startDay
    }
    
    private static let maximumWeeksInMonth = 6
    private static let daysInWeek = 7
    private static let sundayToMondayOffset = 5
    
    public var itemHeight = ItemHeight.fixed(height: 55) {
        didSet {
            if oldValue != itemHeight {
                heightConstraint.isActive = false
                updateHeightConstraint()
                collectionView.collectionViewLayout = createLayout()
                if isInitialised {
                    (collectionView.collectionViewLayout as? MonthCalendarLayout)?.initialised()
                }
            }
        }
    }
    @Published public var currentMonth: MonthDelta?
    public var itemConfigurationHandler: ((Date) -> UIContentConfiguration)?
    public var hasEventConfigurationHandler: ((Date) -> Bool)?
    public var baselineAnchor: NSLayoutYAxisAnchor {
        layoutMarginsGuide.bottomAnchor
    }
    public var selectedDate: Date? {
        collectionView.indexPathsForSelectedItems?.first
            .flatMap { dataSource.itemIdentifier(for: $0) }
            .flatMap { date(for: $0) }
    }
    
    @Published var today: Day!
    let startDay: Weekday
    
    private let axis: Axis
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    private let pageSize = 5
    private var minPage = -2
    private var maxPage = 1
    private var calendar = Calendar(identifier: .gregorian)
    private var cancellables = Set<AnyCancellable>()
    private var heightConstraint: NSLayoutConstraint!
    private var selectionPassthroughSubject = PassthroughSubject<Void, Never>()
    private var isInitialised = false
    private lazy var dataSource: UICollectionViewDiffableDataSource<Month, Day> = {
        let cellRegistration = self.cellRegistration
        return UICollectionViewDiffableDataSource<Month, Day>(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
        }
    }()
    private lazy var cellRegistration = UICollectionView.CellRegistration<CalendarCell, Day> { [weak self] cell, indexPath, day in
        cell.day = day
        cell.isToday = day == self?.today
        
        guard let self = self,
              let date = self.date(for: day) else {
            return
        }
        
        cell.weekday = Weekday(rawValue: (self.calendar.component(.weekday, from: date) + Self.sundayToMondayOffset) % Self.daysInWeek)!
        cell.hasEvent = self.hasEventConfigurationHandler?(date) ?? false
        cell.contentConfiguration = self.itemConfigurationHandler?(date) ?? MonthCalendarDayContentConfiguration(tintColor: self.tintColor)
    }
    private lazy var collectionViewDelegate = CollectionViewDelegate(selectionPassthroughSubject: selectionPassthroughSubject) { [weak self] in
        guard let item = self?.dataSource.itemIdentifier(for: $0) else {
            return false
        }
        return item.isAccessory == false
    }
    
    public init(
        axis: Axis,
        startDay: Weekday = .monday
    ) {
        self.axis = axis
        self.startDay = startDay
        super.init(frame: .zero)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        self.axis = .horizontal
        self.startDay = .monday
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        self.axis = Axis(rawValue: coder.decodeInteger(forKey: CodingKeys.axis.rawValue)) ?? .horizontal
        self.startDay = Weekday(rawValue: coder.decodeInteger(forKey: CodingKeys.startDay.rawValue)) ?? .monday
        super.init(coder: coder)
        commonInit()
    }
    
    public override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(axis.rawValue, forKey: CodingKeys.axis.rawValue)
        coder.encode(startDay.rawValue, forKey: CodingKeys.startDay.rawValue)
    }
    
    private func commonInit() {
        layoutMargins.left = .margin(.medium)
        layoutMargins.right = .margin(.medium)
        
        calendar.timeZone = TimeZone.current
        calculateToday()
        
        setUp(collectionView: collectionView)
        addSubview(collectionView)
        setUpConstraints()
        
        mask = UIView()
        mask?.backgroundColor = .black
        
        updateHeightConstraint()
        
        NotificationCenter.default.publisher(for: .NSCalendarDayChanged)
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] _ in
                calculateToday()
                collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if !isInitialised {
            var snapshot = NSDiffableDataSourceSnapshot<Month, Day>()
            
            let months = [
                months(for: -2),
                months(for: -1),
                months(for: 0),
                months(for: 1)
            ].flatMap { $0 }
            snapshot.appendSections(months)
            months.forEach {
                snapshot.appendItems(days(for: $0), toSection: $0)
            }
            
            dataSource.apply(snapshot) { [weak self] in
                guard let self = self else { return }
                
                let today = self.calendar.dateComponents([.day, .month, .year], from: Date())
                if let indexPath = self.dataSource.indexPath(for: Day(day: today.day!, month: .init(month: today.month!, year: today.year!), isAccessory: false)) {
                    self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
                    self.selectionPassthroughSubject.send(())
                }
                
                self.skipToToday(animated: false)
                (self.collectionView.collectionViewLayout as? MonthCalendarLayout)?.initialised()
            }
            isInitialised = true
        }
    }
    
    private func updateHeightConstraint() {
        switch itemHeight {
        case .fixed(let height):
            heightConstraint = heightAnchor.constraint(equalToConstant: height * CGFloat(Self.maximumWeeksInMonth))
        case .fractionalWidth(let fraction):
            heightConstraint = heightAnchor.constraint(equalTo: widthAnchor, multiplier: CGFloat(Self.maximumWeeksInMonth) * (fraction / CGFloat(Self.daysInWeek)))
        }
        heightConstraint.isActive = true
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        mask?.frame = CGRect(x: 0, y: 0, width: bounds.width, height: mask!.bounds.height)
    }
}

// MARK: Set Up

@available(iOS 14.0, tvOS 14.0, *)
extension MonthCalendarView {
    
    private func setUp(collectionView: UICollectionView) {
        collectionView.backgroundColor = .clear
        collectionView.collectionViewLayout = createLayout()
        collectionView.dataSource = dataSource
        collectionView.decelerationRate = .fast
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.clipsToBounds = true
        collectionView.delegate = collectionViewDelegate
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.bounces = false
        collectionView.allowsMultipleSelection = false
        collectionView.allowsMultipleSelectionDuringEditing = false
    }
    
    private func setUpConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = MonthCalendarLayout.layout(
            forItemHeight: itemHeight,
            pageSize: pageSize,
            axis: axis,
            layoutMargins: layoutMargins
        )
        layout.prependSectionsHandler = { [unowned self] completion in
            var snapshot = dataSource.snapshot()
            guard !snapshot.sectionIdentifiers.isEmpty else {
                completion()
                return
            }
            let months = months(for: minPage - 1)
            snapshot.insertSections(months, beforeSection: snapshot.sectionIdentifiers.first!)
            months.forEach {
                snapshot.appendItems(days(for: $0), toSection: $0)
            }
            dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
                self?.minPage -= 1
                completion()
            }
        }
        layout.appendSectionsHandler = { [unowned self] completion in
            var snapshot = dataSource.snapshot()
            guard !snapshot.sectionIdentifiers.isEmpty else {
                completion()
                return
            }
            let months = months(for: maxPage + 1)
            snapshot.insertSections(months, afterSection: snapshot.sectionIdentifiers.last!)
            months.forEach {
                snapshot.appendItems(days(for: $0), toSection: $0)
            }
            dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
                self?.maxPage += 1
                completion()
            }
            
        }
        layout.layoutHeightUpdateHandler = { [unowned self] in
            mask?.frame.size.height = $0
            layoutMargins = UIEdgeInsets(top: 0, left: layoutMargins.left, bottom: bounds.height - $0, right: layoutMargins.right)
        }
        layout.currentSectionDeltaHandler = { [unowned self] in
            let currentMonth = dataSource.snapshot().sectionIdentifiers[$0]
            let nextMonth = dataSource.snapshot().sectionIdentifiers[$1]
            self.currentMonth = MonthDelta(currentMonth: currentMonth, nextMonth: nextMonth, delta: $2)
        }
        return layout
    }
}

// MARK: Help Functions

@available(iOS 14.0, tvOS 14.0, *)
extension MonthCalendarView {
    
    private func date(for day: Day) -> Date? {
        var dateComponents = DateComponents()
        dateComponents.day = day.day
        dateComponents.month = day.month.month
        dateComponents.year = day.month.year
        return calendar.date(from: dateComponents)
    }
    
    private func months(for page: Int) -> [Month] {
        let months = page * pageSize
        return (months ..< months + pageSize).map {
            var dateComponents = DateComponents()
            dateComponents.month = $0
            let date = calendar.date(byAdding: dateComponents, to: Date(), wrappingComponents: false)!
            let components = calendar.dateComponents([.month, .year], from: date)
            return Month(month: components.month!, year: components.year!)
        }
    }
    
    private func days(for month: Month) -> [Day] {
        let firstDateComponents = DateComponents(
            calendar: calendar,
            year: month.year,
            month: month.month,
            day: 1
        )
        let firstDate = firstDateComponents.date!
        let monthStartDay = (calendar.component(.weekday, from: firstDate) + Self.sundayToMondayOffset - startDay.rawValue) % Self.daysInWeek
        
        let prefixDays: [Day] = (0 ..< monthStartDay)
            .map {
                let date = calendar.date(byAdding: .day, value: -($0 + 1), to: firstDate, wrappingComponents: false)!
                let dateComponents = calendar.dateComponents([.day, .month, .year], from: date)
                return Day(day: dateComponents.day!, month: Month(month: dateComponents.month!, year: dateComponents.year!), isAccessory: true)
            }
            .reversed()
        
        let monthInterval = calendar.dateInterval(of: .month, for: firstDate)!
        let numberOfDaysInMonth = calendar.dateComponents([.day], from: monthInterval.start, to: monthInterval.end).day!
        let monthDays: [Day] = (1 ... numberOfDaysInMonth)
            .map {
                Day(
                    day: $0,
                    month: month,
                    isAccessory: false
                )
            }
        
        let monthEndDay = (calendar.component(.weekday, from: monthInterval.end) - 1 + Self.sundayToMondayOffset - startDay.rawValue) % Self.daysInWeek
        
        let postfixDays: [Day] = (0 ..< 6 - monthEndDay)
            .map {
                let date = calendar.date(byAdding: .day, value: $0 + 1, to: firstDate, wrappingComponents: false)!
                let dateComponents = calendar.dateComponents([.day, .month, .year], from: date)
                return Day(day: dateComponents.day!, month: Month(month: dateComponents.month!, year: dateComponents.year!), isAccessory: true)
            }
        
        return prefixDays + monthDays + postfixDays
    }
    
    private func calculateToday() {
        let today = calendar.dateComponents([.day, .month, .year], from: Date())
        self.today = Day(day: today.day!, month: .init(month: today.month!, year: today.year!), isAccessory: false)
    }
}

// MARK: Collection View Delegate

@available(iOS 14.0, tvOS 14.0, *)
extension MonthCalendarView {
    
    class CollectionViewDelegate: NSObject, UICollectionViewDelegate {
        
        let selectionPassthroughSubject: PassthroughSubject<Void, Never>
        let shouldSelectItemHandler: (IndexPath) -> Bool
        
        init(
            selectionPassthroughSubject: PassthroughSubject<Void, Never>,
            shouldSelectItemHandler: @escaping (IndexPath) -> Bool
        ) {
            self.selectionPassthroughSubject = selectionPassthroughSubject
            self.shouldSelectItemHandler = shouldSelectItemHandler
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            ((scrollView as? UICollectionView)?.collectionViewLayout as? MonthCalendarLayout)?.recalibrate()
        }
        
        func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
            ((scrollView as? UICollectionView)?.collectionViewLayout as? MonthCalendarLayout)?.recalibrate()
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            selectionPassthroughSubject.send(())
        }
        
        func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
            selectionPassthroughSubject.send(())
        }
        
        func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
            shouldSelectItemHandler(indexPath)
        }
        
        func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
            shouldSelectItemHandler(indexPath)
        }
        
        func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
            false
        }
    }
    
}

// MARK: Actions

@available(iOS 14.0, tvOS 14.0, *)
extension MonthCalendarView {
    
    public func skipForwardMonth(animated: Bool) {
        switch axis {
        case .horizontal:
            var contentOffset = collectionView.contentOffset
            contentOffset.x += collectionView.bounds.width
            collectionView.scrollRectToVisible(CGRect(x: contentOffset.x, y: 0, width: collectionView.bounds.width, height: collectionView.bounds.height), animated: animated)
        case .vertical:
            guard let currentIndexPath = collectionView.indexPathsForVisibleItems.sorted(by: <).first else {
                return
            }
            let y = collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: currentIndexPath.section + 1))?.frame.minY ?? 0
            collectionView.scrollRectToVisible(CGRect(x: 0, y: y, width: collectionView.bounds.width, height: collectionView.bounds.height), animated: animated)
        }
    }
    
    public func skipBackwardMonth(animated: Bool) {
        switch axis {
        case .horizontal:
            var contentOffset = collectionView.contentOffset
            contentOffset.x -= collectionView.bounds.width
            collectionView.scrollRectToVisible(CGRect(x: contentOffset.x, y: 0, width: collectionView.bounds.width, height: collectionView.bounds.height), animated: animated)
        case .vertical:
            guard let currentIndexPath = collectionView.indexPathsForVisibleItems.sorted(by: <).first else {
                return
            }
            let y = collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: currentIndexPath.section - 1))?.frame.minY ?? 0
            collectionView.scrollRectToVisible(CGRect(x: 0, y: y, width: collectionView.bounds.width, height: collectionView.bounds.height), animated: animated)
        }
    }
    
    public func skipToToday(animated: Bool) {
        let section = abs(minPage * pageSize)
        switch axis {
        case .horizontal:
            let x = (CGFloat(section) * collectionView.bounds.width)
            collectionView.scrollRectToVisible(CGRect(x: x, y: 0, width: collectionView.bounds.width, height: collectionView.bounds.height), animated: animated)
        case .vertical:
            let y = collectionView.layoutAttributesForItem(at: IndexPath(item: 0, section: section))?.frame.minY ?? 0
            collectionView.scrollRectToVisible(CGRect(x: 0, y: y, width: collectionView.bounds.width, height: collectionView.bounds.height), animated: animated)
        }
    }
    
    public func reload() {
        collectionView.reloadData()
    }
    
}

// MARK: Publishers

@available(iOS 14.0, tvOS 14.0, *)
extension MonthCalendarView {
    
    public func dateSelectionPublisher() -> AnyPublisher<Date?, Never> {
        selectionPassthroughSubject
            .share()
            .map { [weak self] in
                self?.selectedDate
            }
            .eraseToAnyPublisher()
    }
    
}

@available(iOS 14.0, tvOS 14.0, *)
extension MonthCalendarView {
    
    public enum Weekday: Int {
        case monday = 0, tuesday, wednesday, thursday, friday, saturday, sunday
    }
    
    public struct Month: Hashable {
        public let month: Int
        public let year: Int
    }
    
    public struct Day: Hashable {
        public let day: Int
        public let month: Month
        public let isAccessory: Bool
    }
    
    public struct MonthDelta: Hashable {
        public let currentMonth: Month
        public let nextMonth: Month
        public let delta: CGFloat
    }
    
    public enum ItemHeight: Equatable {
        case fixed(height: CGFloat)
        case fractionalWidth(fraction: CGFloat)
    }
    
    public enum Axis: Int, Equatable {
        case horizontal = 0, vertical
    }
}


#endif
