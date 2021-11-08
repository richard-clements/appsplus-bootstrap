import Foundation

public enum RetryState: Hashable {
    case refresh
    case page
}

public enum PagingState: Hashable {
    case idle
    case initialLoad
    case initialLoadError
    case refreshing
    case refreshingError
    case paging
    case pagingError
    
    public func canPage() -> Bool {
        self == .idle
    }
    
    public func canRefresh() -> Bool {
        [.idle, .paging, .pagingError].contains(self)
    }
    
    mutating public func failed() {
        switch self {
        case .initialLoad:
            self = .initialLoadError
        case .refreshing:
            self = .refreshingError
        case .paging:
            self = .pagingError
        default:
            break
        }
    }
    
    public func retry() -> RetryState? {
        switch self {
        case .idle, .refreshingError, .initialLoadError:
            return .refresh
        case .pagingError:
            return .page
        default:
            return nil
        }
    }
}
