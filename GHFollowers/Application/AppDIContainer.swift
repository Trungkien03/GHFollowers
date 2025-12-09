//
//  AppDIContainer.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation

/// App-level Dependency Injection Container - manages shared dependencies
final class AppDIContainer {

    // MARK: - Network Layer
    lazy var networkService: NetworkServiceProtocol = {
        NetworkService(session: .shared)
    }()

    lazy var baseURL: URL = {
        URL(string: "https://api.github.com")!
    }()

    // MARK: - Data Layer (Shared)
    lazy var persistenceManager: PersistenceManagerProtocol = {
        PersistenceManager()
    }()

    // MARK: - Image Cache
    lazy var imageCacheManager: ImageCacheManager = {
        ImageCacheManager.shared
    }()
}
