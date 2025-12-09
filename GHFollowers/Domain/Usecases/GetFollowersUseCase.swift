//
//  GetFollowersUseCase.swift
//  GHFollowers
//
//  Created by Auto on 9/12/25.
//

import Foundation

/// Use Case để lấy danh sách followers của một user
final class GetFollowersUseCase {
    private let repository: FollowerRepositoryProtocol
    
    init(repository: FollowerRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(username: String, page: Int) async throws -> [Follower] {
        return try await repository.getFollowers(for: username, page: page)
    }
}

