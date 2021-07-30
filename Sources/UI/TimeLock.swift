import Foundation

struct TimeLock {
    
    enum TimeLockError: Error {
        case tooEarly
    }
    
    let timeLockInterval: TimeInterval
    private var lastLock: Date?
    
    init(timeLockInterval: TimeInterval) {
        self.timeLockInterval = timeLockInterval
    }
    
    mutating func lock() {
        lastLock = Date()
    }
    
    func unlock() throws {
        if let lastLock = lastLock {
            guard Date().timeIntervalSince(lastLock) >= timeLockInterval else {
                throw TimeLockError.tooEarly
            }
        }
    }
    
}

