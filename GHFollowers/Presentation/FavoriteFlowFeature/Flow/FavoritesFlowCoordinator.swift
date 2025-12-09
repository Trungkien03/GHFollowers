//
//  FavoritesFlowCoordinator.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import SafariServices
import UIKit

/// Flow Coordinator for Favorites module
final class FavoritesFlowCoordinator: Coordinator, FlowRouting {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var parentCoordinator: Coordinator?

    private let dependencies: FavoritesFlowFeatureDIContainer

    init(
        navigationController: UINavigationController,
        dependencies: FavoritesFlowFeatureDIContainer
    ) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        let viewController = dependencies.makeFavoritesListViewController(
            coordinator: self
        )
        viewController.title = "Favorites"
        viewController.tabBarItem = UITabBarItem(
            tabBarSystemItem: .favorites,
            tag: 1
        )
        navigationController.pushViewController(viewController, animated: false)
    }

    /// Navigate to FollowerList screen
    func showFollowerList(for username: String) {
        let viewController = dependencies.makeFollowerListViewController(
            username: username,
            coordinator: self
        )
        viewController.title = username
        navigationController.pushViewController(viewController, animated: true)
    }

    /// Navigate to UserInfo screen
    func showUserInfo(for username: String, delegate: FollowerListVCDelegate?) {
        let viewController = dependencies.makeUserInfoViewController(
            username: username,
            coordinator: self,
            delegate: delegate
        )
        let navController = UINavigationController(
            rootViewController: viewController
        )
        navigationController.present(navController, animated: true)
    }

    func showGitHubProfile(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        if let presentedVC = navigationController.presentedViewController {
            presentedVC.present(safariVC, animated: true)
        } else {
            navigationController.present(safariVC, animated: true)
        }
    }

    func showFollowerListFromUserInfo(for username: String) {
        dismissUserInfo()

        // If FollowerListVC exists, refresh and pop back; otherwise push new
        if let followerListVC = navigationController.viewControllers.first(
            where: { $0 is FollowerListVC }) as? FollowerListVC
        {
            followerListVC.updateUsername(username)
            navigationController.popToViewController(
                followerListVC,
                animated: true
            )
            return
        }
        // Push new
        showFollowerList(for: username)
    }

    func dismissUserInfo() {
        navigationController.presentedViewController?.dismiss(animated: true)
    }
}
