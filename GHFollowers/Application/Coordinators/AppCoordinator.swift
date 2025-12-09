//
//  AppCoordinator.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import UIKit

/// Main Coordinator manage TabBar and main flows
final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var parentCoordinator: Coordinator?

    private let window: UIWindow
    private let dependencyContainer: DIContainer

    init(window: UIWindow, dependencyContainer: DIContainer) {
        self.window = window
        self.dependencyContainer = dependencyContainer
        self.navigationController = UINavigationController()
    }

    func start() {
        let tabBarController = UITabBarController()
        UITabBar.appearance().tintColor = .systemGreen

        // Create Search Coordinator
        let searchNavController = UINavigationController()
        let searchCoordinator = SearchCoordinator(
            navigationController: searchNavController,
            dependencyContainer: dependencyContainer
        )
        searchCoordinator.parentCoordinator = self
        addChild(searchCoordinator)
        searchCoordinator.start()

        // Create Favorites Coordinator
        let favoritesNavController = UINavigationController()
        let favoritesCoordinator = FavoritesCoordinator(
            navigationController: favoritesNavController,
            dependencyContainer: dependencyContainer
        )
        favoritesCoordinator.parentCoordinator = self
        addChild(favoritesCoordinator)
        favoritesCoordinator.start()

        // Setup TabBar
        tabBarController.viewControllers = [
            searchNavController,
            favoritesNavController,
        ]

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        configureNavigationBar()
    }

    private func configureNavigationBar() {
        UINavigationBar.appearance().tintColor = .systemGreen
    }
}
