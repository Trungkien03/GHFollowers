//
//  FollowerRepository.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation

/// Implementation của FollowerRepositoryProtocol
final class FollowerRepository: FollowerRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    private let baseURL: URL
    
    init(networkService: NetworkServiceProtocol, baseURL: URL) {
        self.networkService = networkService
        self.baseURL = baseURL
    }
    
    func getFollowers(for username: String, page: Int) async throws -> [Follower] {
        let endpoint = GitHubFollowersEndpoint(username: username, page: page)
        return try await networkService.fetch(endpoint, baseURL)
    }
    
    func searchUsers(for query: String, page: Int) async throws -> GithubUserSearchResponse {
        let endpoint = GithubUsersEndpoint(username: query, page: page)
        return try await networkService.fetch(endpoint, baseURL)
    }
}

