#if canImport(Foundation)

import Foundation

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
public struct UpdateRequest<T> {
    
    public static func create() -> UpdateRequest {
        UpdateRequest(
            predicate: nil,
            limit: nil,
            offset: nil,
            batchSize: nil,
            sortDescriptors: nil,
            shouldCreate: true,
            shouldUpdate: false,
            prevalidator: nil,
            modifier: nil
        )
    }
    
    public static func update(orCreate: Bool) -> UpdateRequest {
        UpdateRequest(
            predicate: nil,
            limit: nil,
            offset: nil,
            batchSize: nil,
            sortDescriptors: nil,
            shouldCreate: orCreate,
            shouldUpdate: true,
            prevalidator: nil,
            modifier: nil
        )
    }
    
    let predicate: NSPredicate?
    let limit: Int?
    let offset: Int?
    let batchSize: Int?
    let sortDescriptors: [NSSortDescriptor]?
    let shouldCreate: Bool
    let shouldUpdate: Bool
    let prevalidator: ((T, SynchronousStorage) -> Bool)?
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
                prevalidator: nil,
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
                prevalidator: nil,
                modifier: nil
            )
        )
    }
    
    func limit(_ limit: Int) -> UpdateRequest {
        join(
            UpdateRequest(
                predicate: nil,
                limit: limit,
                offset: nil,
                batchSize: nil,
                sortDescriptors: nil,
                shouldCreate: false,
                shouldUpdate: false,
                prevalidator: nil,
                modifier: nil
            )
        )
    }
    
    func offset(_ offset: Int) -> UpdateRequest {
        join(
            UpdateRequest(
                predicate: nil,
                limit: nil,
                offset: offset,
                batchSize: nil,
                sortDescriptors: nil,
                shouldCreate: false,
                shouldUpdate: false,
                prevalidator: nil,
                modifier: nil
            )
        )
    }
    
    func batchSize(_ batchSize: Int) -> UpdateRequest {
        join(
            UpdateRequest(
                predicate: nil,
                limit: nil,
                offset: nil,
                batchSize: batchSize,
                sortDescriptors: nil,
                shouldCreate: false,
                shouldUpdate: false,
                prevalidator: nil,
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
    
    func prevalidate(_ validation: @escaping ((T, SynchronousStorage) -> Bool)) -> UpdateRequest {
        join(
            UpdateRequest(
                predicate: nil,
                limit: nil,
                offset: nil,
                batchSize: nil,
                sortDescriptors: nil,
                shouldCreate: false,
                shouldUpdate: false,
                prevalidator: { item, storage in
                    [
                        prevalidator,
                        validation
                    ]
                    .compactMap { $0?(item, storage) }
                    .allSatisfy { $0 }
                },
                modifier: nil
            )
        )
    }
    
    func prevalidate(_ validation: @escaping (T) -> Bool) -> UpdateRequest {
        prevalidate { item, _ in validation(item) }
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
                prevalidator: nil,
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
            prevalidator: request.prevalidator ?? prevalidator,
            modifier: request.modifier ?? modifier
        )
    }
}

#endif
