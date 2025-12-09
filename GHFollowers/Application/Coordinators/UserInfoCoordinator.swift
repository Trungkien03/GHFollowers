//
//  UserInfoCoordinator.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import SafariServices
import UIKit

/// Coordinator manage UserInfo flow
final class UserInfoCoordinator: Coordinator {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    var parentCoordinator: Coordinator?

    private let dependencyContainer: DIContainer
    private let username: String
    private weak var followerListDelegate: FollowerListVCDelegate?

    init(
        navigationController: UINavigationController,
        dependencyContainer: DIContainer,
        username: String,
        followerListDelegate: FollowerListVCDelegate?
    ) {
        self.navigationController = navigationController
        self.dependencyContainer = dependencyContainer
        self.username = username
        self.followerListDelegate = followerListDelegate
    }

    func start() {
        let viewModel = UserInfoViewModel(
            username: username,
            getUserInfoUseCase: dependencyContainer.getUserInfoUseCase
        )
        let viewController = UserInfoVC(
            viewModel: viewModel,
            coordinator: self,
            followerListDelegate: followerListDelegate
        )
        let navController = UINavigationController(
            rootViewController: viewController
        )
        navigationController.present(navController, animated: true)
    }

    /// open GitHub profile in Safari
    func showGitHubProfile(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        if let presentedVC = navigationController.presentedViewController {
            presentedVC.present(safariVC, animated: true)
        } else {
            navigationController.present(safariVC, animated: true)
        }
    }

    /// Navigate to FollowerList with new username
    func showFollowerList(for username: String) {
        dismiss()

        // find FollowerListCoordinator trong parent hierarchy
        if let followerListCoordinator = findFollowerListCoordinator() {
            followerListCoordinator.requestFollowerRefresh(for: username)
        } else {
            // if not find, then create new one
            let followerListCoordinator = FollowerListCoordinator(
                navigationController: navigationController,
                dependencyContainer: dependencyContainer,
                username: username
            )
            parentCoordinator?.addChild(followerListCoordinator)
            followerListCoordinator.start()
        }
    }

    /// Dismiss UserInfo screen
    func dismiss() {
        navigationController.presentedViewController?.dismiss(animated: true)
        finish()
    }

    /// Helper để tìm FollowerListCoordinator trong hierarchy
    private func findFollowerListCoordinator() -> FollowerListCoordinator? {
        var current: Coordinator? = parentCoordinator
        while let coordinator = current {
            if let followerListCoordinator = coordinator
                as? FollowerListCoordinator
            {
                return followerListCoordinator
            }
            current = coordinator.parentCoordinator
        }
        return nil
    }
}
