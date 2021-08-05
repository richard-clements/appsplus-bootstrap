#if canImport(Foundation)

import Foundation

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
struct UpdateRequest<T> {
    
    static func create() -> UpdateRequest {
        return UpdateRequest(predicate: nil, limit: nil, offset: nil, batchSize: nil, sortDescriptors: nil, shouldCreate: true, shouldUpdate: false, modifier: nil)
    }
    
    static func update(orCreate: Bool) -> UpdateRequest {
        return UpdateRequest(predicate: nil, limit: nil, offset: nil, batchSize: nil, sortDescriptors: nil, shouldCreate: orCreate, shouldUpdate: true, modifier: nil)
    }
    
    let predicate: NSPredicate?
    let limit: Int?
    let offset: Int?
    let batchSize: Int?
    let sortDescriptors: [NSSortDescriptor]?
    let shouldCreate: Bool
    let shouldUpdate: Bool
    let modifier: ((T, SynchronousStorage) -> Void)?
    
    func sorted<Value>(by keyPath: KeyPath<T, Value>, ascending: Bool) -> UpdateRequest {
        let sortDescriptors = [
            self.sortDescriptors,
            [NSSortDescriptor(keyPath: keyPath, ascending: ascending)]
        ]
        .compactMap { $0 }
        .flatMap { $0 }
        
        return join(
            UpdateRequest(
                predicate: nil,
                limit: nil,
                offset: nil,
                batchSize: nil,
                sortDescriptors: sortDescriptors,
                shouldCreate: false,
                shouldUpdate: false,
                modifier: nil
            )
        )
    }
    
    private func setPredicate(_ predicate: NSPredicate) -> UpdateRequest {
        guard shouldUpdate else {
            fatalError("Can not filter on a create request")
        }
        return join(
            UpdateRequest(
                predicate: predicate,
                limit: nil,
                offset: nil,
                batchSize: nil,
                sortDescriptors: nil,
                shouldCreate: false,
                shouldUpdate: false,
                modifier: nil
            )
        )
    }
    
    func suchThat(predicate: NSPredicate) -> UpdateRequest {
        setPredicate(PredicateHelper.suchThat(predicate: predicate, from: self.predicate))
    }
    
    func and(predicate: NSPredicate) -> UpdateRequest {
        setPredicate(PredicateHelper.and(predicate: predicate, from: self.predicate))
    }
    
    func or(predicate: NSPredicate) -> UpdateRequest {
        setPredicate(PredicateHelper.or(predicate: predicate, from: self.predicate))
    }
    
    func excluding(predicate: NSPredicate) -> UpdateRequest {
        setPredicate(PredicateHelper.excluding(predicate: predicate, from: self.predicate))
    }
    
    func modify(_ modifier: @escaping ((T, SynchronousStorage) -> Void)) -> UpdateRequest {
        join(
            UpdateRequest(
                predicate: nil,
                limit: nil,
                offset: nil,
                batchSize: nil,
                sortDescriptors: nil,
                shouldCreate: false,
                shouldUpdate: false,
                modifier: {
                    self.modifier?($0, $1)
                    modifier($0, $1)
                }
            )
        )
    }
    
    func modify(_ modifier: @escaping ((T) -> Void)) -> UpdateRequest {
        modify { value, _ in modifier(value) }
    }
    
    private func join(_ request: UpdateRequest) -> UpdateRequest {
        UpdateRequest(
            predicate: request.predicate ?? predicate,
            limit: request.limit ?? limit,
            offset: request.offset ?? offset,
            batchSize: request.batchSize ?? batchSize,
            sortDescriptors: request.sortDescriptors ?? sortDescriptors,
            shouldCreate: request.shouldCreate || shouldCreate,
            shouldUpdate: request.shouldUpdate || shouldUpdate,
            modifier: request.modifier ?? modifier
        )
    }
}

#endif
