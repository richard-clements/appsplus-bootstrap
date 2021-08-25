import CoreData
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
enum NSManagedObjectFutureError: Error {
    case noContext
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension NSManagedObject {
    
    public func future<Output>(_ closure: @escaping () throws -> Output) -> AnyPublisher<Output, Error> {
        Future { [weak self] promise in
            guard let context = self?.managedObjectContext else {
                promise(.failure(NSManagedObjectFutureError.noContext))
                return
            }
            context.perform {
                do {
                    let output = try closure()
                    promise(.success(output))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension Optional where Wrapped: NSManagedObject {
    
    public func future<Output>(_ closure: @escaping () throws -> Output) -> AnyPublisher<Output, Error> {
        self?.future(closure) ?? Fail(error: NSManagedObjectFutureError.noContext).eraseToAnyPublisher()
    }
    
}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension Array where Element: NSManagedObject {
    
    public func future<Output>(_ closure: @escaping () throws -> Output) -> AnyPublisher<Output, Error> {
        first.future(closure)
    }
    
}
