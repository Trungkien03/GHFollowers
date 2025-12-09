//
//  UserRepository.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation

/// Implementation of UserRepositoryProtocol
final class UserRepository: UserRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let baseURL: URL

    init(networkService: NetworkServiceProtocol, baseURL: URL) {
        self.networkService = networkService
        self.baseURL = baseURL
    }

    func getUserInfo(for username: String) async throws -> User {
        let endpoint = GetUserInfo(username: username)
        return try await networkService.fetch(endpoint, baseURL)
    }
}
