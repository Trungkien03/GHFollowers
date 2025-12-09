//
//  SearchCoordinator.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import UIKit

/// Coordinator manage Search flow
final class SearchCoordinator: Coordinator {
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
        let viewModel = SearchViewModel(
            searchUsersUseCase: dependencyContainer.searchUsersUseCase
        )
        let viewController = SearchVC(viewModel: viewModel, coordinator: self)
        viewController.title = "Search"
        viewController.tabBarItem = UITabBarItem(
            tabBarSystemItem: .search,
            tag: 0
        )
        navigationController.pushViewController(viewController, animated: false)
    }

    /// Navigate to FollowerList screen
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
