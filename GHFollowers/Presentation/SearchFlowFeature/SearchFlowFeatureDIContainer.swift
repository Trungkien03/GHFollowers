//
//  SearchFlowFeatureDIContainer.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation

/// Feature DIContainer for Search/FollowerList/UserInfo module
final class SearchFlowFeatureDIContainer {

    struct Dependencies {
        let networkService: NetworkServiceProtocol
        let baseURL: URL
        let persistenceManager: PersistenceManagerProtocol
    }

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - Repositories
    private lazy var followerRepository: FollowerRepositoryProtocol = {
        FollowerRepository(
            networkService: dependencies.networkService,
            baseURL: dependencies.baseURL
        )
    }()

    private lazy var userRepository: UserRepositoryProtocol = {
        UserRepository(
            networkService: dependencies.networkService,
            baseURL: dependencies.baseURL
        )
    }()

    private lazy var favoriteRepository: FavoriteRepositoryProtocol = {
        FavoriteRepository(persistenceManager: dependencies.persistenceManager)
    }()

    // MARK: - Use Cases
    private func makeGetFollowersUseCase() -> GetFollowersUseCase {
        GetFollowersUseCase(repository: followerRepository)
    }

    private func makeSearchUsersUseCase() -> SearchUsersUseCase {
        SearchUsersUseCase(repository: followerRepository)
    }

    private func makeGetUserInfoUseCase() -> GetUserInfoUseCase {
        GetUserInfoUseCase(repository: userRepository)
    }

    private func makeAddFavoriteUseCase() -> AddFavoriteUseCase {
        AddFavoriteUseCase(repository: favoriteRepository)
    }

    // MARK: - ViewModels
    private func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(searchUsersUseCase: makeSearchUsersUseCase())
    }

    private func makeFollowerListViewModel(username: String)
        -> FollowerListViewModel
    {
        FollowerListViewModel(
            username: username,
            getFollowersUseCase: makeGetFollowersUseCase(),
            getUserInfoUseCase: makeGetUserInfoUseCase(),
            addFavoriteUseCase: makeAddFavoriteUseCase()
        )
    }

    private func makeUserInfoViewModel(username: String) -> UserInfoViewModel {
        UserInfoViewModel(
            username: username,
            getUserInfoUseCase: makeGetUserInfoUseCase()
        )
    }

    // MARK: - ViewControllers
    func makeSearchViewController(coordinator: FlowRouting) -> SearchVC {
        SearchVC(
            viewModel: makeSearchViewModel(),
            coordinator: coordinator
        )
    }

    func makeFollowerListViewController(
        username: String,
        coordinator: FlowRouting
    ) -> FollowerListVC {
        FollowerListVC(
            viewModel: makeFollowerListViewModel(username: username),
            coordinator: coordinator
        )
    }

    func makeUserInfoViewController(
        username: String,
        coordinator: FlowRouting,
        delegate: FollowerListVCDelegate?
    ) -> UserInfoVC {
        UserInfoVC(
            viewModel: makeUserInfoViewModel(username: username),
            coordinator: coordinator,
            followerListDelegate: delegate
        )
    }
}
