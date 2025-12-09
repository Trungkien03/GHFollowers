//
//  FollowerListCoordinator.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import UIKit

/// Coordinator manage FollowerList flow
final class FollowerListCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var parentCoordinator: Coordinator?

    private let dependencyContainer: DIContainer
    private let username: String

    init(
        navigationController: UINavigationController,
        dependencyContainer: DIContainer,
        username: String
    ) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
        self.username = username
    }

    func start() {
        let viewModel = FollowerListViewModel(
            username: username,
            getFollowersUseCase: dependencyContainer.getFollowersUseCase,
            getUserInfoUseCase: dependencyContainer.getUserInfoUseCase,
            addFavoriteUseCase: dependencyContainer.addFavoriteUseCase
        )
        let viewController = FollowerListVC(
            viewModel: viewModel,
            coordinator: self
        )
        viewController.title = username
        navigationController.pushViewController(viewController, animated: true)
    }

    /// Navigate to UserInfo screen
    func showUserInfo(for username: String, delegate: FollowerListVCDelegate?) {
        let userInfoCoordinator = UserInfoCoordinator(
            navigationController: navigationController,
            dependencyContainer: dependencyContainer,
            username: username,
            followerListDelegate: delegate
        )
        addChild(userInfoCoordinator)
        userInfoCoordinator.start()
    }

    /// Request refresh followers list with new username
    func requestFollowerRefresh(for username: String) {
        // Update current coordinator với username mới
        if let followerListVC = navigationController.topViewController
            as? FollowerListVC
        {
            followerListVC.updateUsername(username)
        }
    }
}
