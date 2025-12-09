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
    private let appDIContainer: AppDIContainer

    init(window: UIWindow, appDIContainer: AppDIContainer) {
        self.window = window
        self.appDIContainer = appDIContainer
        self.navigationController = UINavigationController()
    }

    func start() {
        let tabBarController = UITabBarController()
        UITabBar.appearance().tintColor = .systemGreen

        let favoritesNavController = configureFavoriteFlow()
        let searchNavController = configureSearchFlow()

        // Setup TabBar
        tabBarController.viewControllers = [
            searchNavController,
            favoritesNavController,
        ]

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()

        configureNavigationBar()
    }

    private func configureSearchFlow() -> UINavigationController {
        // Create Search Flow Feature DIContainer
        let searchFlowDIContainer = SearchFlowFeatureDIContainer(
            dependencies: .init(
                networkService: appDIContainer.networkService,
                baseURL: appDIContainer.baseURL,
                persistenceManager: appDIContainer.persistenceManager
            )
        )

        // Create Search Flow Coordinator
        let searchNavController = UINavigationController()
        let searchFlowCoordinator = SearchFlowCoordinator(
            navigationController: searchNavController,
            dependencies: searchFlowDIContainer
        )
        searchFlowCoordinator.parentCoordinator = self
        addChild(searchFlowCoordinator)
        searchFlowCoordinator.start()

        return searchNavController
    }

    private func configureFavoriteFlow() -> UINavigationController {
        // Create Favorites Flow Feature DIContainer
        let favoritesFlowDIContainer = FavoritesFlowFeatureDIContainer(
            dependencies: .init(
                networkService: appDIContainer.networkService,
                baseURL: appDIContainer.baseURL,
                persistenceManager: appDIContainer.persistenceManager
            )
        )
        // Create Favorites Flow Coordinator
        let favoritesNavController = UINavigationController()
        let favoritesFlowCoordinator = FavoritesFlowCoordinator(
            navigationController: favoritesNavController,
            dependencies: favoritesFlowDIContainer
        )
        favoritesFlowCoordinator.parentCoordinator = self
        addChild(favoritesFlowCoordinator)
        favoritesFlowCoordinator.start()

        return favoritesNavController
    }

    private func configureNavigationBar() {
        UINavigationBar.appearance().tintColor = .systemGreen
    }
}
