#if canImport(CoreData) && canImport(Combine)

import CoreData
import Combine

public struct NSManagedContextScope: Hashable, ExpressibleByStringLiteral {
    private let rawValue: String
    
    public static let write: Self = "write::context"
    public static let main: Self = "main::context"
    
    public init(string: String) {
        self.rawValue = string
    }
    
    public init(stringLiteral: String) {
        self.rawValue = stringLiteral
    }
}

protocol NSManagedContextProvider {
    func context(for scope: NSManagedContextScope) -> NSManagedObjectContext?
}

enum NSManagedObjectContextScopeError: Error {
    case noContextScope
    case noObjectsFound
}

extension Publisher {
    
    public func receive<T: NSManagedObject>(in scope: NSManagedContextScope) -> AnyPublisher<T, Error> where Output == T {
        mapError { $0 as Error }
            .flatMap { (object: NSManagedObject) -> AnyPublisher<T, Error> in
                guard let contextProvider = object.managedObjectContext else {
                    return Fail(error: NSManagedObjectContextScopeError.noContextScope)
                        .eraseToAnyPublisher()
                }
                
                return Future<T, Error> { completion in
                    contextProvider.perform {
                        guard let context = contextProvider.context(for: scope) else {
                            completion(.failure(NSManagedObjectContextScopeError.noContextScope))
                            return
                        }
                        context.perform {
                            do {
                                guard let value = try context.existingObject(with: object.objectID) as? T else {
                                    throw NSManagedObjectContextScopeError.noObjectsFound
                                }
                                completion(.success(value))
                            } catch {
                                completion(.failure(error))
                            }
                        }
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    @available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
    public func receive<T: NSManagedObject>(in scope: NSManagedContextScope) -> AnyPublisher<[T], Error> where Output == [T] {
        mapError { $0 as Error }
        .flatMap { (objects: [NSManagedObject]) -> AnyPublisher<[T], Error> in
            guard let first = objects.first else {
                return Just([])
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            
            guard let contextProvider = first.managedObjectContext else {
                return Fail(error: NSManagedObjectContextScopeError.noContextScope)
                    .eraseToAnyPublisher()
            }
            
            return Future<Output, Error> { completion in
                contextProvider.perform {
                    guard let contextProvider = first.managedObjectContext else {
                        completion(.failure(NSManagedObjectContextScopeError.noContextScope))
                    }
                    context.perform {
                        let value = objects.compactMap { try? context.existingObject(with: $0.objectID) }
                            .compactMap { $0 as? T }
                        completion(.success(value))
                    }
                }
            }
            .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
}

#endif
