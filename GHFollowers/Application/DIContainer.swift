//
//  DependencyContainer.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation

/// Dependency Injection Container - quản lý tất cả dependencies của app
final class DIContainer {

    // MARK: - Network Layer
    private lazy var networkService: NetworkServiceProtocol = {
        NetworkService(session: .shared)
    }()

    private lazy var baseURL: URL = {
        URL(string: "https://api.github.com")!
    }()

    // MARK: - Data Layer
    private lazy var persistenceManager: PersistenceManagerProtocol = {
        PersistenceManager()
    }()

    private lazy var followerRepository: FollowerRepositoryProtocol = {
        FollowerRepository(networkService: networkService, baseURL: baseURL)
    }()

    private lazy var userRepository: UserRepositoryProtocol = {
        UserRepository(networkService: networkService, baseURL: baseURL)
    }()

    private lazy var favoriteRepository: FavoriteRepositoryProtocol = {
        FavoriteRepository(persistenceManager: persistenceManager)
    }()

    // MARK: - Domain Layer (Use Cases)
    lazy var getFollowersUseCase: GetFollowersUseCase = {
        GetFollowersUseCase(repository: followerRepository)
    }()

    lazy var searchUsersUseCase: SearchUsersUseCase = {
        SearchUsersUseCase(repository: followerRepository)
    }()

    lazy var getUserInfoUseCase: GetUserInfoUseCase = {
        GetUserInfoUseCase(repository: userRepository)
    }()

    lazy var getFavoritesUseCase: GetFavoritesUseCase = {
        GetFavoritesUseCase(repository: favoriteRepository)
    }()

    lazy var addFavoriteUseCase: AddFavoriteUseCase = {
        AddFavoriteUseCase(repository: favoriteRepository)
    }()

    lazy var removeFavoriteUseCase: RemoveFavoriteUseCase = {
        RemoveFavoriteUseCase(repository: favoriteRepository)
    }()

    // MARK: - Image Cache
    lazy var imageCacheManager: ImageCacheManager = {
        ImageCacheManager.shared
    }()
}
