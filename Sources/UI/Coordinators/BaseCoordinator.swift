#if canImport(UIKit) && (os(iOS) || os(tvOS) || os(macOS))

import UIKit

protocol Coordinator: AnyObject {
    
    var childCoordinators: [Coordinator] { get set }
    func start()
    
}

open class BaseCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator] = []
    
    func start() {
        // Implementation specific to the coordinator
    }
    
    func addChildCoordinator(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChildCoordinator(_ coordinator: Coordinator?) {
        guard let coordinator = coordinator else { return }
        childCoordinators.removeAll { $0 === coordinator }
    }
    
}

#endif
