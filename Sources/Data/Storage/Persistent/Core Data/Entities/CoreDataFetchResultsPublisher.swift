#if canImport(Foundation) && canImport(Combine) && canImport(CoreData)

import Foundation
import CoreData
import Combine

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
struct CoreDataFetchResultsPublisher<Entity>: Publisher {

    typealias Output = [Entity]
    typealias Failure = Error

    let context: NSManagedObjectContext
    let fetchRequest: NSFetchRequest<NSFetchRequestResult>

    init(context: NSManagedObjectContext, fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        self.context = context
        self.fetchRequest = fetchRequest
    }

    func receive<S>(subscriber: S) where S: Subscriber, Error == S.Failure, [Entity] == S.Input {
        let subscription = Subscription(subscriber: subscriber, request: fetchRequest, context: context)
        subscriber.receive(subscription: subscription)
    }

}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension CoreDataFetchResultsPublisher {

    @available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
    class Subscription<S>: NSObject, NSFetchedResultsControllerDelegate where S: Subscriber, Failure == S.Failure, Output == S.Input {
        private var subscriber: S?
        private var controller: NSFetchedResultsController<NSFetchRequestResult>?

        init(subscriber: S?, request: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext) {
            if request.sortDescriptors == nil {
                request.sortDescriptors = [NSSortDescriptor(keyPath: \NSManagedObject.objectID, ascending: true)]
            }
            controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            self.subscriber = subscriber
            super.init()
            controller?.delegate = self
        }

        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            let results = controller.fetchedObjects?.compactMap { $0 as? Entity } ?? []
            guard let subscriber = subscriber else {
                return
            }
            _ = subscriber.receive(results)
        }
    }

}

@available(iOS 13.0, tvOS 13.0, macOS 10.15, watchOS 6.0, *)
extension CoreDataFetchResultsPublisher.Subscription: Subscription {

    func request(_ demand: Subscribers.Demand) {
        guard let subscriber = subscriber else { return }
        do {
            try controller?.performFetch()
            let results = controller?.fetchedObjects?.compactMap { $0 as? Entity } ?? []
            _ = subscriber.receive(results)
        } catch {
            subscriber.receive(completion: .failure(error))
        }
    }

    func cancel() {
        subscriber = nil
        controller = nil
    }

}


#endif
