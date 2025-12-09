//
//  Coordinator.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import UIKit

/// Protocol for all coordinator classes
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
    var parentCoordinator: Coordinator? { get set }

    func start()
    func finish()
}

extension Coordinator {
    /// Add child coordinator
    func addChild(_ coordinator: Coordinator) {
        childCoordinators.append(coordinator)
        coordinator.parentCoordinator = self
    }

    /// Remove child coordinator
    func removeChild(_ coordinator: Coordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }

    /// Finish coordinator và remove khỏi parent
    func finish() {
        parentCoordinator?.removeChild(self)
    }
}
