//
//  FollowerRepositoryProtocol.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation

/// Protocol định nghĩa các operations liên quan đến Followers
protocol FollowerRepositoryProtocol {
    func getFollowers(for username: String, page: Int) async throws -> [Follower]
    func searchUsers(for query: String, page: Int) async throws -> GithubUserSearchResponse
}

