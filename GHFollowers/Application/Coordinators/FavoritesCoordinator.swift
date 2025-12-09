//
//  FavoritesCoordinator.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import UIKit

/// Coordinator quản lý Favorites flow
final class FavoritesCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var parentCoordinator: Coordinator?

    private let dependencyContainer: DIContainer

    init(
        navigationController: UINavigationController,
        dependencyContainer: DIContainer
    ) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
    }

    func start() {
        let viewModel = FavoritesListViewModel(
            getFavoritesUseCase: dependencyContainer.getFavoritesUseCase,
            removeFavoriteUseCase: dependencyContainer.removeFavoriteUseCase
        )
        let viewController = FavoritesListVC(
            viewModel: viewModel,
            coordinator: self
        )
        viewController.title = "Favorites"
        viewController.tabBarItem = UITabBarItem(
            tabBarSystemItem: .favorites,
            tag: 1
        )
        navigationController.pushViewController(viewController, animated: false)
    }

    /// Navigate đến FollowerList screen
    func showFollowerList(for username: String) {
        let followerListCoordinator = FollowerListCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer,
            username: username
        )
        addChild(followerListCoordinator)
        followerListCoordinator.start()
    }
}
